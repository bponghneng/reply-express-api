defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordTokenController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.Services.UserNotifier
  alias ReplyExpress.Accounts.UsersContext

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"email" => email}) do
    result = UsersContext.generate_password_reset_token(%{email: email})

    with {:ok, %UserTokenProjection{} = user_token_projection} <- result do
      token = Base.encode64(user_token_projection.token)

      UserNotifier.deliver_reset_password_instructions(
        {"", user_token_projection.user.email},
        Application.get_env(:reply_express, :reset_password_url),
        token
      )

      send_resp(conn, 204, "")
    end
  end
end
