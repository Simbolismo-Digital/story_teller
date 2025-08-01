defmodule StoryTeller.Universe do
  alias StoryTeller.Llm.Gemini

  def opening_scene() do
    context()
    |> Gemini.chat("Generate the opening scene of a mythic RPG world.")
  end

  defp context() do
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

    Agora, gere a cena de abertura de um mundo mítico de RPG.
    """
  end
end
