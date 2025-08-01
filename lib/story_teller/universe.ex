defmodule StoryTeller.Universe do
  @moduledoc """
  The universe of a mythic RPG world.

  StoryTeller.Universe.play_n_turns(10) |> StoryTeller.Universe.print_story()
  """
  alias StoryTeller.Llm.Gemini

  require Logger

  def opening_scene() do
    Logger.info("🌅 Generating opening scene...")

    context()
    |> Gemini.chat("Generate the opening scene of a mythic RPG world.")
  end

  def next_scene(%StoryTeller.Scene{} = scene, model_story) do
    Logger.info("➡️ Generating next scene from current scene at #{scene.location}...")

    {:ok, next_json_scene, next_model_story} =
      context()
      |> Gemini.chat(
        scene
        |> Jason.encode!(),
        model_story
      )

    case StoryTeller.Json.extract_json_block(next_json_scene) do
      {:error, text} ->
        Logger.warning("⚠️ Could not extract JSON block. Using fallback text.")
        {:ok, %{scene | description: text}, next_model_story}

      json_response ->
        next_scene =
          json_response
          |> Jason.decode!()
          |> StoryTeller.Scene.parse()

        Logger.info("✅ Next scene generated at #{next_scene.location}")
        {:ok, %{next_scene | story: [scene | scene.story]}, next_model_story}
    end
  end

  def turn(last_scene \\ nil, story_log \\ [])

  def turn(_last_scene, []) do
    Logger.info("🌀 Starting new story with opening scene...")
    {:ok, raw_scene, model_story} = opening_scene()

    scene =
      raw_scene
      |> StoryTeller.Json.extract_json_block()
      |> Jason.decode!()
      |> StoryTeller.Scene.parse()
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

  def print_story([]), do: IO.puts("Nenhuma cena registrada.")

  def print_story(scenes) when is_list(scenes) do
    # Log sync
    :timer.sleep(1000)

    scenes
    |> Enum.with_index(1)
    |> Enum.each(fn {scene, index} ->
      IO.puts("\n===== TURNO #{index} =====")
      IO.puts("\n📍 Local: #{scene.location}\n")
      IO.puts("📖 Cena:\n#{scene.description}\n")

      if index == 1 do
        IO.puts("\n🧙 Personagens:")

        Enum.each(scene.players, fn player ->
          IO.puts("- #{player.name} (#{player.race} #{player.class})")
          IO.puts("  🎒 Background: #{player.backstory}")

          if Map.get(player, :equipment) do
            IO.puts("  🧰 Equipamento: #{player.equipment}")
          end

          if Map.has_key?(player, :npc) do
            IO.puts("  🧑‍🤝‍🧑 NPC: #{player.npc}")
          end

          IO.puts("")
        end)
      end

      if Enum.any?(scene.actions) do
        IO.puts("🎭 Ações:")

        Enum.each(scene.actions, fn %{"character" => c, "action" => a} ->
          IO.puts("- #{c}: #{a}")
        end)
      else
        IO.puts("⚠️  Nenhuma ação registrada.")
      end
    end)

    IO.puts("\n===== FIM DA HISTÓRIA =====\n")
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
