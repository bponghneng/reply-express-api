defmodule ReplyExpressWeb.API.V1.UserSessionController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts
  alias ReplyExpressWeb.UserAuth

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password),
      do: UserAuth.log_in_user(conn, user),
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      else: json(conn, %{errors: %{user: ["Invalid email or password"]}})
  end

  def delete(conn, _params) do
    UserAuth.log_out_user(conn)
  end
end
