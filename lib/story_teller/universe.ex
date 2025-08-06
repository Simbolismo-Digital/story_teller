defmodule StoryTeller.Universe do
  @moduledoc """
  The universe of a mythic RPG world.

  StoryTeller.Universe.play_n_turns(10) |> StoryTeller.Scene.Export.print_story_to_file("output.md")
  """
  alias StoryTeller.Llm.Gemini

  require Logger

  @scene_memory 2

  def play(turns, output_file) do
    StoryTeller.Universe.play_n_turns(turns)
    |> StoryTeller.Scene.Export.print_story_to_file(output_file)
  end

  def opening_scene() do
    Logger.info("🌅 Generating opening scene...")

    context()
    |> Gemini.chat("Generate the opening scene of a mythic RPG world.")
  end

  def next_scene(%StoryTeller.Scene{} = scene, model_story) do
    Logger.info("➡️ Generating next scene from current scene at #{scene.location}...")

    {:ok, next_json_scene, next_model_story} =
      context()
      |> Gemini.chat(Jason.encode!(scene), model_story)

    case StoryTeller.Json.extract_json_block(next_json_scene) do
      {:error, text} ->
        Logger.warning("⚠️ Could not extract JSON block. Using fallback text.")
        {:ok, %{scene | description: text}, next_model_story}

      json_response ->
        next_scene = StoryTeller.Scene.parse(json_response)

        story =
          [scene | scene.story || []]
          |> flatten_story()
          |> Enum.take(@scene_memory)

        Logger.info("✅ Next scene generated at #{next_scene.location}")
        {:ok, %{next_scene | story: story}, next_model_story}
    end
  end

  def flatten_story([]), do: []

  def flatten_story([%{story: story} = scene | rest]) do
    [Map.put(scene, :story, []) | flatten_story(story ++ rest)]
  end

  def turn(last_scene \\ nil, story_log \\ [])

  def turn(_last_scene, []) do
    Logger.info("🌀 Starting new story with opening scene...")
    {:ok, raw_scene, model_story} = opening_scene()

    scene =
      StoryTeller.Scene.parse(raw_scene)
      |> StoryTeller.Action.make_actions(model_story)

    Logger.info("✅ Opening scene parsed and actions made.")
    {:ok, scene, model_story}
  end

  def turn(last_scene, story_log) do
    Logger.info("🔁 Advancing story with new turn.")
    {:ok, next_scene, model_story} = next_scene(last_scene, story_log)
    acted_scene = StoryTeller.Action.make_actions(next_scene, model_story)
    Logger.info("🎭 Actions taken in scene at #{acted_scene.location}")
    {:ok, acted_scene, model_story}
  end

  def play_n_turns(n, scene \\ nil, story \\ [], acc \\ [])

  def play_n_turns(0, _scene, _story, acc) do
    Logger.info("🏁 Story complete. #{length(acc)} turns played.")
    Enum.reverse(acc)
  end

  def play_n_turns(n, scene, story, acc) do
    Logger.info("▶️ Turn #{length(acc) + 1} of #{n + length(acc)}")
    {:ok, new_scene, new_story} = turn(scene, story)
    play_n_turns(n - 1, new_scene, new_story, [new_scene | acc])
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
end
