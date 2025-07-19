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

  @doc """
  Adds a user to a team.
  """
  def add_user(conn, %{"uuid" => team_uuid} = params) do
    user_params = %{
      "team_uuid" => team_uuid,
      "user_uuid" => params["user_uuid"],
      "role" => params["role"]
    }

    with {:ok, team} <- TeamsContext.add_user_to_team(user_params) do
      conn
      |> put_status(:ok)
      |> put_view(TeamsJSON)
      |> render(:show, team: team)
    end
  end
end
