defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordControllerTest do
  @moduledoc false

  use ReplyExpressWeb.ConnCase

  import ReplyExpress.Factory

  import ReplyExpress.Factory

  describe "POST /api/v1/users/reset-password" do
  @valid_email "test@email.local"

  describe "POST /api/v1/users/reset_password" do
    setup do
      user =
        :user_projection
        |> build(email: @valid_email)
        |> set_user_projection_password(@valid_password)
        |> insert()

      # Simulate the generation of a reset password token
      token_context = "reset_password"

      user_token =
        :user_token_projection
        |> build(user: user, context: token_context)
        |> insert()

      encoded_token = Base.encode64(user_token.token)

      {:ok, user: user, user_token: user_token, encoded_token: encoded_token}
    end

    test "successfully resets password and returns 204", %{
      conn: conn,
      encoded_token: encoded_token,
      user: user
    } do
      params = %{
        "email" => user.email,
        "password" => @valid_password,
        "password_confirmation" => @valid_password,
        "token" => encoded_token
      }

      result =
        conn
        |> post(~p"/api/v1/users/reset-password", params)
        |> response(204)

      assert result == ""
    end

    test "returns 422 when params are missing", %{conn: conn} do
      result =
        conn
        |> post(~p"/api/v1/users/reset-password", %{})
        |> json_response(422)

      assert result["errors"]["password"] == ["can't be empty"]
      assert result["errors"]["token"] == ["can't be empty"]
      assert result["errors"]["uuid"] == ["can't be empty"]
    end

    test "returns 422 for invalid token", %{conn: conn, user: user} do
      params = %{
        "email" => user.email,
        "password" => @valid_password,
        "password_confirmation" => @valid_password,
        "token" => Base.encode64("invalidtoken"),
        "uuid" => user.uuid
      }

      result =
        conn
        |> post(~p"/api/v1/users/reset-password", params)
        |> json_response(422)

      assert result["errors"]["token"] == ["invalid token"]
      assert result["errors"]["uuid"] == ["can't be empty"]
    end
  end
end
