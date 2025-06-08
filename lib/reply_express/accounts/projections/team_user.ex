defmodule ReplyExpress.Accounts.Projections.TeamUser do
  @moduledoc """
  Ecto schema for the teams_users join table, representing the association between teams and users.
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @timestamps_opts [type: :utc_datetime_usec]

  @type t :: %__MODULE__{
          id: integer() | nil,
          role: String.t() | nil,
          team_id: integer() | nil,
          user_id: integer() | nil,
          team: TeamProjection.t() | Ecto.Association.NotLoaded.t() | nil,
          user: UserProjection.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "teams_users" do
    field :role, :string
    belongs_to :team, TeamProjection
    belongs_to :user, UserProjection

    timestamps()
  end
end
