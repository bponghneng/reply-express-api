defmodule ReplyExpress.Accounts.Projections.User do
  @moduledoc """
  Backing schema for user state projected from events
  """

  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field(:confirmed_at, :utc_datetime)
    field(:email, :string)
    field(:hashed_password, :string)

    timestamps()
  end
end
