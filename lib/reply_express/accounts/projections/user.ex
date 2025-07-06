defmodule ReplyExpress.Accounts.Projections.User do
  @moduledoc """
  Backing schema for user state projected from events
  """

  use Ecto.Schema

  alias ReplyExpress.Accounts.Projections.Team
  alias ReplyExpress.Accounts.Projections.TeamUser
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @timestamps_opts [type: :utc_datetime_usec]

  @type t :: %__MODULE__{
          id: integer() | nil,
          confirmed_at: DateTime.t() | nil,
          email: String.t() | nil,
          hashed_password: String.t() | nil,
          logged_in_at: DateTime.t() | nil,
          uuid: binary() | nil,
          user_tokens: [UserTokenProjection.t()] | Ecto.Association.NotLoaded.t() | nil,
          team_users: [TeamUser.t()] | Ecto.Association.NotLoaded.t() | nil,
          teams: [Team.t()] | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "users" do
    field :confirmed_at, :utc_datetime
    field :email, :string
    field :hashed_password, :string
    field :logged_in_at, :utc_datetime
    field :uuid, :binary_id

    has_many :user_tokens, UserTokenProjection, foreign_key: :user_uuid, references: :uuid
    has_many :team_users, TeamUser, foreign_key: :user_uuid, references: :uuid

    many_to_many :teams, Team,
      join_through: TeamUser,
      join_keys: [user_uuid: :uuid, team_uuid: :uuid]

    timestamps()
  end
end
