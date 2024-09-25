defmodule ReplyExpress.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :user_uuid, :uuid
      add :uuid, :uuid

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:user_tokens, [:user_id])
    create unique_index(:user_tokens, [:context, :token])
    create unique_index(:user_tokens, [:context, :user_uuid])
    create unique_index(:user_tokens, [:uuid])
  end
end
