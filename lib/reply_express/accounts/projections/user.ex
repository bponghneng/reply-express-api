defmodule ReplyExpress.Accounts.Projections.User do
  @moduledoc """
  Backing schema for user state projected from events
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field :confirmed_at, :utc_datetime
    field :email, :string
    field :hashed_password, :string
    field :logged_in_at, :utc_datetime
    field :uuid, :binary_id

    has_many :user_tokens, UserTokenProjection

    timestamps()
  end
end
