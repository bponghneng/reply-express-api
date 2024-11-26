defmodule ReplyExpress.Accounts.Projections.TeamRole do
  @moduledoc """
  Backing schema for team role state projected from events
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @timestamps_opts [type: :utc_datetime_usec]

  schema "team_roles" do
    field :name, :string
    field :user_uuid, :binary_id
    field :uuid, :binary_id

    belongs_to :user, UserProjection

    timestamps()
  end
end
