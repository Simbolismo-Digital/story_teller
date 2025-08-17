defmodule StoryTeller.Player.Action do
  alias StoryTeller.Json
  alias StoryTeller.Llm.Gemini

  @table :player_action
  @story_key :story

  @max_story 20

  def act(source, target, action) do
    story = load_story()

    {:ok, result, story} =
      Gemini.chat(
        "Estamos descrevendo as ações dos personagens",
        context(source, target, action),
        story
      )

    save_story(story)

    {:ok, Json.trim_after_json_fence(result),
     result
     |> Json.extract_json_block()
     |> Jason.decode!()}
  end

  def context(source, target, action) do
    """
    Descreva em detalhes ac cena resultante da ação entre os personagens.

    A fonte da cena precisa ter papel ativo. A action deve ser a reação do alvo.

    Ao final da cena retorne um mapa json com {action: "Reação do alvo."}
    Adicione ao mapa outras chaves originais do alvo se alguma deles mudou durante a ação.

    Fonte: #{inspect(source)}
    Alvo: #{inspect(target)}
    Ação: #{action}
    """
  end

  def ensure_ets do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public])
    end
  end

  defp save_story(story) do
    trimmed = Enum.take(story, -@max_story)
    :ets.insert(@table, {@story_key, trimmed})
  end

  defp load_story do
    case :ets.lookup(@table, @story_key) do
      [{@story_key, memory}] -> memory
      _ -> []
    end
  end
end
