defmodule StoryTeller.Scene.Export do
  def print_story_to_file(scenes, path \\ "output.md")

  def print_story_to_file([], path) do
    message = "# 📭 Nenhuma cena registrada.\n"
    File.write!(path, message)
  end

  def print_story_to_file(scenes, path) when is_list(scenes) do
    output =
      scenes
      |> Enum.with_index(1)
      |> Enum.reduce([], fn {scene, index}, acc ->
        turn_header = """
        ## TURNO #{index}

        **📍 Local:** #{scene.location}

        **📖 Cena:**
        #{scene.description}
        """

        players_section =
          if index == 1 do
            players =
              scene.players
              |> Enum.map(fn player ->
                equipment =
                  if Map.get(player, :equipment),
                    do: "- 🧰 Equipamento: #{player.equipment}\n",
                    else: ""

                npc =
                  if Map.has_key?(player, :npc), do: "- 🧑‍🤝‍🧑 NPC: #{player.npc}\n", else: ""

                """
                - **#{player.name}** (#{player.race} #{player.class})
                  - 🎒 Background: #{player.backstory}
                  #{equipment}#{npc}
                """
              end)
              |> Enum.join("\n")

            "### 🧙 Personagens:\n\n" <> players
          else
            ""
          end

        actions_section =
          if Enum.any?(scene.actions) do
            actions =
              scene.actions
              |> Enum.map(fn %{"character" => c, "action" => a} ->
                "- **#{c}**: #{a}"
              end)
              |> Enum.join("\n")

            "\n### 🎭 Ações:\n\n" <> actions
          else
            "\n⚠️ Nenhuma ação registrada."
          end

        acc ++ [turn_header, players_section, actions_section]
      end)
      |> Enum.join("\n\n---\n\n")

    final_output = output <> "\n\n## 🏁 FIM DA HISTÓRIA\n"

    File.write!(path, final_output)
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
end
