defmodule ReplyExpressWeb.API.V1.Users.SessionControllerTest do
  use ReplyExpressWeb.ConnCase

  @invalid_credentials %{email: "test@email", password: "1234"}
  @valid_credentials %{email: "test@email.local", password: "password1234"}

  alias ReplyExpress.Accounts.Projections.UserToken
  alias ReplyExpress.Repo

  describe "POST /api/v1/users/log_in" do
    test "sets cookie with token for session tracking", context do
      :user_projection
      |> build(email: @valid_credentials.email)
      |> set_user_projection_password(@valid_credentials.password)
      |> insert()

      response =
        post(context.conn, ~p"/api/v1/users/log_in", %{"credentials" => @valid_credentials})

      token = UserToken |> Repo.one() |> Map.get(:token)

      assert response.cookies["session"] == token
    end

    test "renders errors for invalid data", context do
      :user_projection
      |> build(email: @valid_credentials.email)
      |> set_user_projection_password(@valid_credentials.password)
      |> insert()

      response =
        context.conn
        |> post(~p"/api/v1/users/log_in", %{"credentials" => @invalid_credentials})
        |> json_response(422)

      assert response["errors"]["credentials"] == ["are invalid"]
    end

    test "handles empty POST body", context do
      response =
        context.conn
        |> post(~p"/api/v1/users/log_in", %{})
        |> json_response(422)

      assert response["errors"]["credentials"] == ["is required"]
    end
  end
end
