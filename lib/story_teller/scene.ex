defmodule StoryTeller.Scene do
  defstruct [
    :description,
    :location,
    players: [],
    npcs: [],
    items: [],
    story: [],
    actions: []
  ]

  def parse(%{"scene" => scene}) do
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
