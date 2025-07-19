defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordControllerTest do
  @moduledoc false

  use ReplyExpressWeb.ConnCase

  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Commanded

  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "POST /api/v1/users/reset-password" do
    setup do
      cmd_register_user = %CreateUser{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(cmd_register_user, consistency: :strong)

      cmd_reset =
        GeneratePasswordResetToken.new(%{email: @valid_credentials.email})
        |> GeneratePasswordResetToken.assign_uuid(UUID.uuid4())
        |> GeneratePasswordResetToken.build_reset_password_token()
        |> GeneratePasswordResetToken.set_user_properties()

      :ok = Commanded.dispatch(cmd_reset, consistency: :strong)

      user_token = Repo.one(UserTokenProjection)

      {:ok, encoded_token: Base.encode64(user_token.token)}
    end

    test "successfully resets password and returns 204", %{
      conn: conn,
      encoded_token: encoded_token
    } do
      params = %{
        "password" => @valid_credentials.password,
        "password_confirmation" => @valid_credentials.password,
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
    end

    test "returns 422 for invalid token", %{conn: conn} do
      params = %{
        "password" => @valid_credentials.password,
        "password_confirmation" => @valid_credentials.password,
        "token" => Base.encode64("invalidtoken")
      }

      result =
        conn
        |> post(~p"/api/v1/users/reset-password", params)
        |> json_response(422)

      assert result["errors"]["token"] == ["invalid token"]
    end
  end
end
