defmodule ReplyExpress.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams) do
      add :name, :string
      add :uuid, :uuid

      timestamps()
    end

    create unique_index(:teams, [:name])
    create unique_index(:teams, [:uuid])

    create table(:team_roles) do
      add :name, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :user_uuid, :uuid
      add :uuid, :uuid

      timestamps()
    end

    create unique_index(:team_roles, [:name, :user_uuid])
    create unique_index(:team_roles, [:uuid])
  end
end
