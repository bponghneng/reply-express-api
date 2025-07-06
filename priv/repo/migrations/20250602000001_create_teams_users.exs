defmodule ReplyExpress.Repo.Migrations.CreateTeamsUsers do
  use Ecto.Migration

  def change do
    create table(:teams_users) do
      add :team_uuid, references(:teams, column: :uuid, on_delete: :delete_all, type: :uuid),
        null: false

      add :user_uuid, references(:users, column: :uuid, on_delete: :delete_all, type: :uuid),
        null: false

      add :role, :string, null: false

      timestamps()
    end

    create index(:teams_users, [:team_uuid])
    create index(:teams_users, [:user_uuid])
    create unique_index(:teams_users, [:team_uuid, :user_uuid])
  end
end
