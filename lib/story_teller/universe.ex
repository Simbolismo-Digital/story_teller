defmodule StoryTeller.Universe do
  alias StoryTeller.Llm.Gemini

  def opening_scene() do
    context()
    |> Gemini.chat("Generate the opening scene of a mythic RPG world.")
  end

  def make_actions(%StoryTeller.Scene{players: players} = scene) do
    actions =
      Enum.flat_map(players, fn
        %{name: "Lysandra"} ->
          [%{character: "Lysandra", action: "Diz a Torvin: olá, meu amigo."}]

        _ ->
          []
      end)

    %StoryTeller.Scene{scene | actions: actions}
  end

  def next_scene(%StoryTeller.Scene{} = scene, model_story) do
    {:ok, next_json_scene, next_model_story} =
      context()
      |> Gemini.chat(
        scene
        |> Jason.encode!(),
        model_story
      )

    next_scene =
      next_json_scene
      |> extract_json_block()
      |> Jason.decode!()
      |> StoryTeller.Scene.parse()

    {:ok, %{next_scene | story: [scene | scene.story]}, next_model_story}
  end

  def context() do
    """
    Você é um simulador de mundos de RPG. Retorne um JSON estruturado descrevendo uma cena e os personagens presentes.

    Formato:
    {
      "scene": {
        "description": "...",
        "location": "...",
        "players": [
          {
            "name": "Drakaw",
            "race": "Meio-dragão",
            "class": "Bardo",
            "backstory": "Fugiu do Circo de Lunei..."
          }
        ]
      }
    }

    Eu vou seguir te respondendo em formato json, com a cena e as ações tomadas pelos personagens.
    E você continuará respondendo a próxima cena e nós repetiremos essa dinâmica.

    Agora, gere a cena de abertura de um mundo mítico de RPG.
    """
  end

  def extract_json_block("```json\n" <> rest) do
    rest
    |> String.trim()
    |> String.trim_trailing("```")
  end

  def extract_json_block(text), do: text
end
