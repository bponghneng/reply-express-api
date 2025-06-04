defmodule ReplyExpressWeb.API.V1.TeamsJSON do
  @moduledoc """
  Renders JSON for team-related responses (Context7 style).
  """
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection

  @doc """
  Renders a single team's creation details.
  """
  def create(%{team: %TeamProjection{} = team}) do
    %{data: data(team)}
  end

  defp data(%TeamProjection{} = team) do
    %{
      uuid: team.uuid,
      name: team.name
    }
  end
end
