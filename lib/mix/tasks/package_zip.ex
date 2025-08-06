defmodule Mix.Tasks.Package.Zip do
  use Mix.Task

  @shortdoc "Zips the current project directory as story_teller.zip, excluding build artifacts"

  @impl true
  def run(_args) do
    zip_name = "story_teller.zip"

    IO.puts("📦 Creating #{zip_name} (excluding _build, deps, .git)...")

    {output, exit_code} =
      System.cmd(
        "zip",
        [
          "-r",
          zip_name,
          ".",
          "-FS",
          "-x",
          "deps/*",
          "_build/*",
          ".git/*",
          "story_teller.zip",
          "cover/*",
          "doc/*"
        ],
        stderr_to_stdout: true,
        into: IO.stream(:stdio, :line)
      )

    if exit_code == 0 do
      Mix.shell().info("✅ ZIP package created: #{zip_name}")
    else
      Mix.raise("❌ Failed to create zip:\n#{output}")
    end
  end
end
