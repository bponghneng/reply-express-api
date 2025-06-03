defmodule ReplyExpress.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :uuid, :uuid

      timestamps()
    end

    create unique_index(:teams, [:uuid])
  end
end
