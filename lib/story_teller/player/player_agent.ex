defmodule StoryTeller.Player.Agent do
  use GenServer

  alias StoryTeller.Cli.TextFx
  alias StoryTeller.Player.Action, as: PlayerAction
  alias StoryTeller.Player
  alias StoryTeller.Repo
  ## API

  def start_link(%Player{name: name} = player) do
    GenServer.start_link(__MODULE__, player, name: via(name))
  end

  def get(name), do: GenServer.call(via(name), :get)
  def update(name, fun), do: GenServer.cast(via(name), {:update, fun})

  def action(actor_name, target_name, action \\ nil) do
    GenServer.call(via(actor_name), {:act_on, target_name, action}, 20_000)
  end

  ## Callbacks

  def init(player) do
    StoryTeller.Player.Action.ensure_ets()
    {:ok, player}
  end

  def handle_call(:get, _from, state), do: {:reply, state, state}

  def handle_call({:act_on, target_name, action}, _from, actor) do
    ts = NaiveDateTime.utc_now()

    action = action || actor.action

    %Player{} = target1 = get(target_name)

    # 1) dispara LLM com ambos os estados atualizados (assíncrono pra não travar loop)
    try do
      {:ok, result, changes} = PlayerAction.act(actor, target1, action)

      event_for_actor = %{
        type: "outgoing_action",
        from: actor.name,
        to: target_name,
        action: action,
        description: result,
        at: ts
      }

      event_for_target = %{
        type: "incoming_action",
        from: actor.name,
        to: target_name,
        action: action,
        description: result,
        at: ts
      }

      # 2) ator lembra e persiste sua ação (campo action)
      actor1 =
        actor
        |> remember(event_for_actor)
        |> Map.put(:action, action)

      upsert!(actor, actor1)

      # 3) alvo lembra de forma sincronizada para garantir consistência
      {:ok, target2} = GenServer.call(via(target_name), {:remember, event_for_target})

      target3 = upsert!(target2, changes)

      Task.async(fn ->
        TextFx.type(result, wait: 200)
        TextFx.type("#{target_name}: #{target3.action}", color: :green)
        if target2.mode == :llm, do: action(target_name, actor.name, target3.action)
      end)

      {:reply, :ok, actor1}
    rescue
      e ->
        require Logger
        Logger.error("LLM react failed: #{Exception.message(e)}")
        {:reply, :error, e}
    end
  end

  # usado pelo ator para pedir ao alvo lembrar
  def handle_call({:remember, event}, _from, state) do
    state1 = remember(state, event)
    {:reply, {:ok, state1}, state1}
  end

  def handle_cast({:update, fun}, state) do
    {:noreply, upsert!(state, fun.(state))}
  end

  ## Private

  @memory_cap 200
  defp remember(%Player{} = p, %{} = event) do
    mem = p.memory || []
    mem1 = [event | mem] |> Enum.take(@memory_cap)
    %Player{p | memory: mem1}
  end

  defp upsert!(%Player{} = player, %Player{} = changes) do
    attrs =
      changes
      |> Map.from_struct()
      |> Map.drop([:__meta__, :id, :inserted_at])

    upsert!(player, attrs)
  end

  defp upsert!(%Player{} = player, %{} = changes) do
    player
    |> Player.changeset(changes)
    |> Ecto.Changeset.put_change(
      :updated_at,
      NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    )
    |> Repo.insert!(
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: :name
    )
  end

  # resultado do Task.async / async_nolink
  def handle_info({ref, _result}, state) when is_reference(ref) do
    # evita receber o :DOWN depois
    Process.demonitor(ref, [:flush])
    {:noreply, state}
  end

  # término do task (caso não tenha sido "flushado")
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    {:noreply, state}
  end

  ## Registry helper

  defp via(name), do: {:via, Registry, {StoryTeller.Player.Registry, name}}
end
