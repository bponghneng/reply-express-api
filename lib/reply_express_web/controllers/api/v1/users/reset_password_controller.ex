defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.Services.UserNotifier

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"email" => email}) do
    result = Accounts.generate_password_reset_token(%{email: email})

    with {:ok, %UserTokenProjection{} = user_token_projection} <- result do
      UserNotifier.deliver_reset_password_instructions(
        {"", user_token_projection.user.email},
        "http://localhost:4000/api/v1/users/change_password"
      )

      send_resp(conn, 204, "")
    end
  end
end
