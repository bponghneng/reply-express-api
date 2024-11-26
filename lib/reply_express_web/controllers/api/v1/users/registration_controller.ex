defmodule ReplyExpressWeb.API.V1.Users.RegistrationController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"user" => user_params}) do
    result = UsersContext.register_user(user_params)

    with {:ok, %UserProjection{} = user} <- result do
      render(conn, :show, user: user)
    end
  end
end
