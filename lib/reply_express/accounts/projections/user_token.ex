defmodule ReplyExpress.Accounts.Projections.UserToken do
  @moduledoc """
  Backing schema for user token state projected from events
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @timestamps_opts [type: :utc_datetime_usec, updated_at: false]

  schema "user_tokens" do
    field :context, :string
    field :sent_to, :string
    field :token, :binary
    field :user_uuid, :binary_id
    belongs_to :user, UserProjection

    timestamps()
  end
end
