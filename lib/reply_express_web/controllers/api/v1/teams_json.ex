defmodule ReplyExpressWeb.API.V1.TeamsJSON do
  @moduledoc """
  Renders JSON for team-related responses.
  """
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.TeamUser, as: TeamUserProjection

  @type team_data :: %{uuid: String.t(), name: String.t(), team_users: list()}
  @type team_user_data :: %{uuid: String.t(), email: String.t(), role: String.t()}

  @doc """
  Renders a single team's creation details.
  """
  def create(%{team: %TeamProjection{} = team}) do
    %{data: data(team)}
  end

  @doc """
  Renders a single team with associated users.
  """
  def show(%{team: %TeamProjection{} = team}) do
    %{data: data(team)}
  end

  @spec data(TeamProjection.t()) :: team_data()
  defp data(%TeamProjection{team_users: team_users} = team) do
    %{
      uuid: team.uuid,
      name: team.name,
      team_users: Enum.map(team_users, &format_team_user/1)
    }
  end

  defp data(%TeamProjection{} = team) do
    %{
      uuid: team.uuid,
      name: team.name,
      team_users: []
    }
  end

  @spec format_team_user(TeamUserProjection.t()) :: team_user_data()
  defp format_team_user(%TeamUserProjection{user: user, role: role}) do
    %{uuid: user.uuid, email: user.email, role: role}
  end
end
