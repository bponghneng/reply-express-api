defmodule ReplyExpressWeb.API.V1.UserRegistrationController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"user" => user_params}) do
    result = Accounts.register_user(user_params)

    with {:ok, %UserProjection{} = user} <- result do
      render(conn, :show, user: user)
    end
  end
end
