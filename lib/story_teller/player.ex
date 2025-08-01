defmodule StoryTeller.Player do
  @derive [Jason.Encoder]
  defstruct [:name, :race, :class, :equipment, :backstory]
end
