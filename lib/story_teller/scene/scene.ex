defmodule StoryTeller.Scene do
  @derive [Jason.Encoder]
  defstruct [
    :description,
    :location,
    players: [],
    npcs: [],
    items: [],
    story: [],
    actions: []
  ]

  alias StoryTeller.Json

  def parse(raw_scene) do
    raw_scene
    |> Json.extract_json_block()
    |> Jason.decode!()
    |> cast()
  end

  def cast(%{"scene" => scene}) do
    %StoryTeller.Scene{
      description: scene["description"],
      location: scene["location"],
      players:
        scene["players"] && Enum.map(scene["players"], &parse_struct(&1, StoryTeller.Player)),
      npcs: scene["npcs"] && Enum.map(scene["npcs"], &parse_struct(&1, StoryTeller.NPC)),
      items: scene["items"] && Enum.map(scene["items"], &parse_struct(&1, StoryTeller.Item))
    }
  end

  defp parse_struct(map, module) do
    map
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    |> then(&struct(module, &1))
  end
end
