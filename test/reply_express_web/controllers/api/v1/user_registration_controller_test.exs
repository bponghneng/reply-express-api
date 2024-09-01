defmodule ReplyExpressWeb.UserRegistrationControllerTest do
  use ReplyExpressWeb.ConnCase, async: true

  describe "POST /api/v1/users/register" do
    test "registers new user account", context do
      email = "test@email.local"

      response =
        post(context.conn, ~p"/api/v1/users/register", %{
          "user" => %{email: email, password: "password1234"}
        })
        |> json_response(200)

      assert response["data"]["email"] == email
    end

    test "renders errors for invalid data", context do
      invalid_email = "test@email"
      invalid_password = "1234"

      response =
        post(context.conn, ~p"/api/v1/users/register", %{
          "user" => %{email: invalid_email, password: invalid_password}
        })
        |> json_response(200)

      assert response["data"]["email"] == invalid_email
    end
  end
end
