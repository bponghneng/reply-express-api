defmodule ReplyExpressWeb.API.V1.TeamsController do
  @moduledoc """
  Controller for team-related operations.
  """

  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts.TeamsContext
  alias ReplyExpressWeb.API.V1.TeamsJSON

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  @doc """
  Creates a new team.
  """
  def create(conn, %{"team" => team_params}) do
    with {:ok, team} <- TeamsContext.create_team(team_params) do
      conn
      |> put_status(:created)
      |> put_view(TeamsJSON)
      |> render(:create, team: team)
    end
  end
end
