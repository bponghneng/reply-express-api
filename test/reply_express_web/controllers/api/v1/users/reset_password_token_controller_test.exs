defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordTokenControllerTest do
  @moduledoc false

  use ReplyExpressWeb.ConnCase

  import Swoosh.TestAssertions

  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Commanded

  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "POST /api/v1/users/reset-password-token" do
    setup do
      cmd_register = %CreateUser{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(cmd_register, consistency: :strong)

      %{cmd_register: cmd_register}
    end

    test "creates new reset password token and sends notification email", %{
      cmd_register: cmd_register,
      conn: conn
    } do
      conn
      |> post(~p"/api/v1/users/reset-password-token", %{"email" => cmd_register.email})
      |> response(204)

      [user_token_projection] = Repo.all(UserTokenProjection)

      assert user_token_projection.context == "reset_password"
      assert user_token_projection.user_id == user_token_projection.user_id
    end

    test "sends notification email", %{cmd_register: cmd_register, conn: conn} do
      conn
      |> post(~p"/api/v1/users/reset-password-token", %{"email" => cmd_register.email})
      |> response(204)

      assert_email_sent(fn sent_email ->
        [{_sent_to_name, sent_to_email}] = sent_email.to

        assert sent_to_email == cmd_register.email
      end)
    end
  end
end
