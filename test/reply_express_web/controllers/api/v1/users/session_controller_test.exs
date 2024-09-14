defmodule ReplyExpressWeb.API.V1.Users.SessionControllerTest do
  use ReplyExpressWeb.ConnCase

  @invalid_credentials %{email: "test@email", password: "1234"}
  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "POST /api/v1/users/log_in" do
    test "creates new user token for session tracking", context do
      :user_projection
      |> build(email: @valid_credentials.email)
      |> set_user_projection_password(@valid_credentials.password)
      |> insert()

      token_context = "session"

      response =
        context.conn
        |> post(~p"/api/v1/users/log_in", %{"credentials" => @valid_credentials})
        |> json_response(200)

      assert response["data"]["token"]
      assert response["data"]["context"] == token_context
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
  end
end
