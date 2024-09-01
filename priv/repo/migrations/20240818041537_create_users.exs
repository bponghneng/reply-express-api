defmodule ReplyExpress.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :uuid, :uuid
      add :confirmed_at, :utc_datetime
      add :email, :string
      add :hashed_password, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:uuid])
  end
end
