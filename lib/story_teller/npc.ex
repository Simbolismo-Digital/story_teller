defmodule StoryTeller.NPC do
  @derive [Jason.Encoder]
  defstruct [:name, :race, :description]
end
