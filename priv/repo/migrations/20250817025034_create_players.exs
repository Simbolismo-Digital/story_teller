defmodule StoryTeller.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :race, :string, null: false
      add :class, :string, null: false
      add :equipment, {:array, :string}
      add :backstory, :text
      add :action, :text
      add :actions, {:array, :string}

      timestamps()
    end

    create unique_index(:players, [:name])
  end
end
