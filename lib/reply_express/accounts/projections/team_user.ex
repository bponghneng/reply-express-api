defmodule ReplyExpress.Accounts.Projections.TeamUser do
  @moduledoc """
  Ecto schema for the teams_users join table, representing the association between teams and users.
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @timestamps_opts [type: :utc_datetime_usec]

  schema "teams_users" do
    field :role, :string
    belongs_to :team, TeamProjection
    belongs_to :user, UserProjection

    timestamps()
  end
end
