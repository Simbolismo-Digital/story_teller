defmodule StoryTeller.Action do
  require Logger

  @doc """
  Gera ações para os personagens de uma cena com base nos objetivos deles.
  """
  def make_actions(%StoryTeller.Scene{} = scene, story_log) do
    Logger.info("🎭 Gerando ações para a cena em #{scene.location}...")

    {:ok, json_response, _model_story} =
      StoryTeller.Llm.Gemini.chat(
        "",
        context_for_actions(scene),
        story_log
      )

    Logger.debug("📝 Ações geradas: #{json_response}")

    case StoryTeller.Json.extract_json_block(json_response) do
      {:error, text} ->
        Logger.warning("⚠️ Não foi possível extrair JSON de ações. Usando texto alternativo.")
        %StoryTeller.Scene{scene | description: text, actions: []}

      json_response ->
        actions =
          Jason.decode!(json_response)
          |> Map.get("actions", [])

        Logger.info("✅ Ações geradas com sucesso para #{length(actions)} personagem(ns).")

        %StoryTeller.Scene{scene | actions: actions}
    end
  end

  defp context_for_actions(scene) do
    """
    Você é um mestre de RPG. Com base na seguinte cena em JSON, uma string `action` para os personagens que forem agir nessa cena.

    ✅ O resultado deve ser estritamente neste formato JSON:
    {
      "actions": [
        {
          "character": "Nome do personagem",
          "action": "Ação que ele toma, como fala ou movimentação."
        }
      ]
    }

    🎯 Use o campo `scene.players`, `scene.npc` ou outro interagível para identificar os sujeitos de ação.

    🎯 Se existir um campo `actions`, use o conteúdo de cada `action` associado ao `player` ou `npc` ou `item`.]

    🎯 Os `scene.players` ou `scene.npc` não precisam agir necessariamente, tornando a narrativa mais dinâmica e menos massante.

    🎯 Quando algum personagem não agir, basta não adicionar em `actions` fazendo cenas mais direcionadas e fáceis de digerir.

    Cena:
    #{Jason.encode!(scene)}
    """
  end
end
