defmodule ReplyExpress.Accounts.Projections.User do
  @moduledoc """
  Backing schema for user state projected from events
  """

  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field :confirmed_at, :utc_datetime
    field :email, :string
    field :hashed_password, :string
    field :logged_in_at, :utc_datetime
    field :uuid, :binary_id

    timestamps()
  end
end
