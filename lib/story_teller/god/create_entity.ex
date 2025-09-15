defmodule StoryTeller.God.CreateEntity do
  alias StoryTeller.Repo

  def create(intent, prompt, struct) do
    {:ok, entities, _story} = StoryTeller.Llm.Gemini.chat(prompt, context(intent, struct))

    entities
    # |> dbg()
    |> StoryTeller.Json.extract_json_block()
    |> Jason.decode!()
    |> Enum.map(&persist_and_spawn!(&1, struct))
  end

  defp persist_and_spawn!(attrs, %module{}) do
    player =
      module.changeset(attrs)
      |> Repo.insert!(on_conflict: :nothing, conflict_target: :name)

    case module.start_link(player) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        :ok

      other ->
        raise "Failed to start #{inspect(module)}: #{inspect(other)}"
    end

    player
  end

  def context(intent, struct) do
    """
    Baseado nas intenções #{inspect(intent)}, crie e preencha os mapas #{inspect(struct)}.
    Retorne numa lista de mapas json.
    Não deixe campos nulos.
    Não coloque \n ou caractéres que formatem linhas.
    Não use `:` para atoms elixir.
    Para o seguinte prompt:
    """
  end
end
