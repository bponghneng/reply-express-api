defmodule ReplyExpressWeb.Users.RegistrationControllerTest do
  use ReplyExpressWeb.ConnCase

  describe "POST /api/v1/users/register" do
    test "registers new user account", context do
      email = "test@email.local"

      response =
        context.conn
        |> post(~p"/api/v1/users/register", %{"user" => %{email: email, password: "password1234"}})
        |> json_response(200)

      assert response["data"]["email"] == email
    end

    test "renders errors for invalid data", context do
      invalid_email = "test@email"
      invalid_password = "1234"

      response =
        context.conn
        |> post(~p"/api/v1/users/register", %{
          "user" => %{email: invalid_email, password: invalid_password}
        })
        |> json_response(422)

      assert response["errors"]["email"] == ["is invalid"]
    end

    test "handles empty POST body", context do
      response =
        context.conn
        |> post(~p"/api/v1/users/register", %{})
        |> json_response(422)

      assert response["errors"]["user"] == ["is required"]
    end
  end
end
