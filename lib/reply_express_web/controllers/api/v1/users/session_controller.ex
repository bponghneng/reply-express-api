defmodule ReplyExpressWeb.API.V1.Users.SessionController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"credentials" => credentials}) do
    result =
      Accounts.log_in_user(%{
        credentials: %{email: credentials["email"], password: credentials["password"]}
      })

    with {:ok, %UserTokenProjection{} = token} <- result do
      render(conn, :show, token: token)
    end
  end
end
