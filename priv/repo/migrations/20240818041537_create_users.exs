defmodule ReplyExpress.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:users) do
      add :confirmed_at, :utc_datetime
      add :email, :string
      add :hashed_password, :string
      add :logged_in_at, :utc_datetime
      add :uuid, :uuid

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
