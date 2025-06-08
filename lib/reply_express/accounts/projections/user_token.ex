defmodule ReplyExpress.Accounts.Projections.UserToken do
  @moduledoc """
  Backing schema for user token state projected from events
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @timestamps_opts [type: :utc_datetime_usec, updated_at: false]

  @type t :: %__MODULE__{
          context: String.t(),
          sent_to: String.t(),
          token: String.t(),
          user: UserProjection.t(),
          user_id: integer,
          user_uuid: String.t(),
          uuid: String.t()
        }

  schema "user_tokens" do
    field :context, :string
    field :sent_to, :string
    field :token, :binary
    field :user_uuid, :binary_id
    field :uuid, :binary_id

    belongs_to :user, UserProjection

    timestamps()
  end
end
