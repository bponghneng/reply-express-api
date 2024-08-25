defmodule ReplyExpressWeb.API.V1.UserConfirmationController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def update(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok, _} ->
        send_resp(conn, 204, "")

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            json(conn, %{errors: %{token: ["Already confirmed"]}})

          %{} ->
            json(conn, %{errors: %{token: ["user link expired or invalid"]}})
        end
    end
  end
end
