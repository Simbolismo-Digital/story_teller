defmodule StoryTeller.Llm.GeminiLimiter do
  @moduledoc """
  Módulo para limitar a taxa de chamadas à API Gemini.

  Dashboard de uso:
  https://aistudio.google.com/usage?project=gen-lang-client-0335571470

  Documentação de cotas:
  https://ai.google.dev/gemini-api/docs/rate-limits
  """
  use GenServer
  require Logger

  @limits %{
    rpm: 15,
    tpm: 250_000,
    rpd: 1_000
  }

  @tokens_per_word 8
  @token_estimate_factor 1.3
  @name __MODULE__

  # API pública

  def start_link(_opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      %{
        queue: :queue.new(),
        rpm: %{},
        tpm: %{},
        rpd: %{},
        drain_pending: false
      },
      name: @name
    )
  end

  @doc """
  Estima a quantidade de tokens com base nas palavras de `context` e `prompt`.
  """
  def estimate_tokens(context, prompt) do
    words =
      [context, prompt]
      |> Enum.join(" ")
      |> String.split()
      |> length()

    tokens = trunc(words * @tokens_per_word * @token_estimate_factor)

    if tokens > @limits.tpm do
      {:error, :tpm_exceeded}
    else
      {:ok, tokens}
    end
  end

  @doc """
  Executa `fun` respeitando os limites de uso. Bloqueia até ser possível.
  """
  def run(token_count, fun) when is_function(fun, 0) do
    GenServer.call(@name, {:request, token_count, fun}, :infinity)
  end

  # GenServer Callbacks

  def init(state), do: {:ok, state}

  def handle_call({:request, token_count, fun}, from, state) do
    now = System.system_time(:second)
    today = Date.utc_today() |> Date.to_string()
    cutoff = now - 60

    rpm = drop_old_entries(state.rpm, cutoff)
    tpm = drop_old_entries(state.tpm, cutoff)
    rpd = Map.take(state.rpd, [today])

    rpm_count = Enum.reduce(Map.values(rpm), 0, &+/2)
    tpm_count = Enum.reduce(Map.values(tpm), 0, &+/2)
    rpd_count = Map.get(rpd, today, 0)

    clean_state = %{state | rpm: rpm, tpm: tpm, rpd: rpd}
    dbg(clean_state)

    if rpm_count < @limits.rpm and tpm_count + token_count <= @limits.tpm and
         rpd_count < @limits.rpd do
      result = fun.()

      updated_state = %{
        clean_state
        | rpm: Map.update(rpm, now, 1, &(&1 + 1)),
          tpm: Map.update(tpm, now, token_count, &(&1 + token_count)),
          rpd: Map.update(rpd, today, 1, &(&1 + 1))
      }

      {:reply, result, updated_state}
    else
      reason =
        cond do
          rpm_count >= @limits.rpm ->
            "RPM (#{rpm_count}/#{@limits.rpm})"

          tpm_count + token_count > @limits.tpm ->
            "TPM (#{tpm_count + token_count}/#{@limits.tpm})"

          rpd_count >= @limits.rpd ->
            "RPD (#{rpd_count}/#{@limits.rpd})"

          true ->
            "desconhecido"
        end

      Logger.info("⏳ Limite atingido: #{reason}. Enfileirando requisição...")
      queue = :queue.in({from, token_count, fun}, clean_state.queue)

      if not clean_state.drain_pending do
        delay = retry_delay(clean_state)
        Logger.debug("⏳ Agendando drain para #{delay}ms")
        Process.send_after(self(), :drain, delay)
        {:noreply, %{clean_state | queue: queue, drain_pending: true}}
      else
        {:noreply, %{clean_state | queue: queue}}
      end
    end
  end

  def handle_info(:drain, state) do
    now = System.system_time(:second)
    today = Date.utc_today() |> Date.to_string()
    cutoff = now - 60

    rpm = drop_old_entries(state.rpm, cutoff)
    tpm = drop_old_entries(state.tpm, cutoff)
    rpd = Map.take(state.rpd, [today])

    clean_state = %{state | rpm: rpm, tpm: tpm, rpd: rpd}
    dbg(clean_state)

    rpm_count = Enum.reduce(Map.values(rpm), 0, &+/2)
    tpm_count = Enum.reduce(Map.values(tpm), 0, &+/2)
    rpd_count = Map.get(rpd, today, 0)

    case :queue.out(state.queue) do
      {{:value, {from, token_count, fun}}, rest_queue} ->
        if rpm_count < @limits.rpm and tpm_count + token_count <= @limits.tpm and
             rpd_count < @limits.rpd do
          Logger.info("✅ Executando requisição liberada da fila.")
          result = fun.()
          GenServer.reply(from, result)

          updated_state = %{
            clean_state
            | queue: rest_queue,
              rpm: Map.update(rpm, now, 1, &(&1 + 1)),
              tpm: Map.update(tpm, now, token_count, &(&1 + token_count)),
              rpd: Map.update(rpd, today, 1, &(&1 + 1))
          }

          send(self(), :drain)
          {:noreply, updated_state}
        else
          reasons =
            for {check, msg} <- [
                  {rpm_count >= @limits.rpm, "RPM (#{rpm_count}/#{@limits.rpm})"},
                  {tpm_count + token_count > @limits.tpm,
                   "TPM (#{tpm_count + token_count}/#{@limits.tpm})"},
                  {rpd_count >= @limits.rpd, "RPD (#{rpd_count}/#{@limits.rpd})"}
                ],
                check,
                do: msg

          Logger.debug(
            "🕒 Ainda bloqueado: [#{Enum.join(reasons, ", ")}]. Reagendando verificação..."
          )

          queue = :queue.in_r({from, token_count, fun}, rest_queue)
          delay = retry_delay(clean_state)
          Logger.debug("⏳ Agendando drain para #{delay}ms")

          Process.send_after(self(), :drain, delay)
          {:noreply, %{clean_state | queue: queue}}
        end

      {:empty, _} ->
        {:noreply, %{clean_state | drain_pending: false}}
    end
  end

  defp drop_old_entries(map, cutoff) do
    Enum.reject(map, fn {ts, _} -> ts <= cutoff end)
    |> Enum.into(%{})
  end

  defp retry_delay(state) do
    now = System.system_time(:second)
    today = Date.utc_today() |> Date.to_string()
    cutoff = now - 60

    oldest_rpm_ts =
      state.rpm
      |> Map.keys()
      |> Enum.filter(&(&1 > cutoff))
      |> Enum.min(fn -> now end)

    oldest_tpm_ts =
      state.tpm
      |> Map.keys()
      |> Enum.filter(&(&1 > cutoff))
      |> Enum.min(fn -> now end)

    rpm_delay = max((oldest_rpm_ts + 60 - now) * 1_000, 1_000)
    tpm_delay = max((oldest_tpm_ts + 60 - now) * 1_000, 1_000)

    rpd_delay =
      if Map.get(state.rpd, today, 0) >= @limits.rpd,
        # 24 horas
        do: 86_400_000,
        else: 1_000

    Enum.max([rpm_delay, tpm_delay, rpd_delay])
  end
end
