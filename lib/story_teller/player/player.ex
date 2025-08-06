defmodule StoryTeller.Player do
  use Ecto.Schema
  import Ecto.Changeset

  alias StoryTeller.Player.Agent, as: PlayerAgent
  alias StoryTeller.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive [Jason.Encoder]

  def start_link(player), do: PlayerAgent.start_link(player)

  def all(), do: Repo.all(__MODULE__)

  schema "players" do
    field :name, :string
    field :race, :string
    field :class, :string
    field :equipment, {:array, :string}
    field :backstory, :string
    field :action, :string
    field :actions, {:array, :string}
    timestamps()
  end

  def changeset(player \\ %__MODULE__{}, attrs) do
    attrs = normalize_equipment(attrs)

    player
    |> cast(attrs, ~w(name race class equipment backstory action actions updated_at)a)
    |> validate_required(~w(name race class)a)
  end

  defp normalize_equipment(%{"equipment" => equipment} = attrs) when is_binary(equipment) do
    normalized =
      equipment
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.map(&capitalize_first/1)

    Map.put(attrs, "equipment", normalized)
  end

  defp normalize_equipment(attrs), do: attrs

  defp capitalize_first(""), do: ""

  defp capitalize_first(str) do
    String.capitalize(str)
  end
end
