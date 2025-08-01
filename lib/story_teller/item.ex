defmodule StoryTeller.Item do
  @derive [Jason.Encoder]
  defstruct [:name, :description]
end
