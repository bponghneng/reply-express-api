defmodule ReplyExpress.Accounts.Projections.Team do
  @moduledoc """
  Backing schema for team state projected from events
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.TeamUser
  alias ReplyExpress.Accounts.Projections.User

  @timestamps_opts [type: :utc_datetime_usec]

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          uuid: binary() | nil,
          team_users: [TeamUser.t()] | Ecto.Association.NotLoaded.t() | nil,
          users: [User.t()] | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "teams" do
    field :name, :string
    field :uuid, :binary_id

    has_many :team_users, TeamUser
    many_to_many :users, User, join_through: TeamUser

    timestamps()
  end
end
