defmodule ReplyExpress.Accounts.TeamsContext do
  @moduledoc """
  Context for team-related operations.
  """

  import Ecto.Query, only: [from: 2]

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Commanded
  alias ReplyExpress.Repo

  @doc """
  Creates a new team.

  Returns `{:ok, team}` on success, or `{:error, reason}` on failure.
  """
  def create_team(attrs) do
    uuid = UUID.uuid4()

    create_team =
      attrs
      |> CreateTeam.new()
      |> CreateTeam.set_name(attrs["name"])
      |> CreateTeam.set_uuid(uuid)

    with :ok <- Commanded.dispatch(create_team, consistency: :strong) do
      case team_by_uuid(uuid) do
        nil -> {:error, :not_found}
        team -> {:ok, team}
      end
    end
  end

  @doc """
  Gets a team by UUID.

  Returns the team if found, or `nil` if not found.
  """
  def team_by_uuid(uuid) do
    Repo.one(from t in TeamProjection, where: t.uuid == ^uuid)
  end
end
