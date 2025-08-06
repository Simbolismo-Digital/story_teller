defmodule Mix.Tasks.Play do
  use Mix.Task

  @shortdoc "Starts the story loop and writes the story to output.md"

  @default_turns 2
  @default_output "story_teller.md"

  @impl true
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      [turns] -> String.to_integer(turns)
      _ -> @default_turns
    end
    |> StoryTeller.Universe.play(@default_output)
  end
end
