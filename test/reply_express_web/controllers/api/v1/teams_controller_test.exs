defmodule ReplyExpressWeb.API.V1.TeamsControllerTest do
  @moduledoc false

  use ReplyExpressWeb.ConnCase

  @valid_team_attrs %{name: "Test Team"}

  describe "create/2" do
    test "creates a team when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/teams", team: @valid_team_attrs)
      assert %{"uuid" => uuid, "name" => name} = json_response(conn, 201)["data"]
      assert name == @valid_team_attrs.name
      assert uuid != nil
    end

    test "returns error when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/teams", team: %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
