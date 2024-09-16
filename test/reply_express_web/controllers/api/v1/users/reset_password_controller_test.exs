defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordControllerTest do
  use ReplyExpressWeb.ConnCase
  import Swoosh.TestAssertions

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  #  @invalid_credentials %{email: "test@email", password: "1234"}
  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "POST /api/v1/users/reset_password" do
    test "creates new reset password token and sends notification email", context do
      user_projection =
        :user_projection
        |> build(email: @valid_credentials.email)
        |> set_user_projection_password(@valid_credentials.password)
        |> insert()

      token_context = "reset_password"

      :user_token_projection
      |> build(
        context: token_context,
        user_id: user_projection.id,
        user_uuid: user_projection.uuid
      )

      context.conn
      |> post(~p"/api/v1/users/reset_password", %{"email" => @valid_credentials.email})
      |> response(204)

      [user_token_projection] = Repo.all(UserTokenProjection)

      assert user_token_projection.context == token_context
      assert user_token_projection.user_id == user_token_projection.user_id
    end

    test "sends notification email", context do
      user_projection =
        :user_projection
        |> build(email: @valid_credentials.email)
        |> set_user_projection_password(@valid_credentials.password)
        |> insert()

      token_context = "reset_password"

      :user_token_projection
      |> build(
        context: token_context,
        user_id: user_projection.id,
        user_uuid: user_projection.uuid
      )

      context.conn
      |> post(~p"/api/v1/users/reset_password", %{"email" => @valid_credentials.email})
      |> response(204)

      assert_email_sent(fn sent_email ->
        [{_sent_to_name, sent_to_email}] = sent_email.to

        assert sent_to_email == user_projection.email
      end)
    end
  end
end
