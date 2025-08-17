defmodule StoryTeller.Repo.Migrations.AddMemoryToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      # {:array, :map} -> jsonb[]; default needs an empty SQL array of jsonb
      add :memory, {:array, :map}, default: fragment("'{}'::jsonb[]"), null: false
      add :mode, :string, default: "llm", null: false
    end

    create index(:players, [:mode])
  end
end
