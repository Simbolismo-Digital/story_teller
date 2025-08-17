defmodule StoryTeller.Oracle do
  @moduledoc false
  import Ecto.Query

  alias StoryTeller.Json
  alias StoryTeller.Llm.Gemini
  alias StoryTeller.Player
  alias StoryTeller.Repo

  def prophesy do
    {:ok, result, _story} = Gemini.chat(context(), "Agora realize seu trabalho, ó grande oráculo")

    description = Json.trim_after_json_fence(result)

    props =
      result
      |> Json.extract_json_block()
      |> Jason.decode!()

    {:ok, description, props}
  end

  defp context do
    """
    Você é o oráculo que pode proferir previsões para o futuro.
    Você reflete todas as memórias de todos os jogadores.
    Retorne uma descrição dos fatos ocorridos e os eventos que desencadeiam.
    Retorne um json com karmas, que podem ser tanto negativos quanto positivos.
    {name: "Person1", karma: "suas aventuras levaram a encontrar seu arqui-inimigo", intent: "criar_players", subjects: ["Person2"]}

    Memórias: #{inspect(list_memories())}
    """
  end

  defp list_memories do
    from(p in Player, select: {p.memory})
    |> Repo.all()
  end
end
