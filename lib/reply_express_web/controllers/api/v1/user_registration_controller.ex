defmodule ReplyExpressWeb.API.V1.UserRegistrationController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, user} <- Accounts.register_user(user_params) do
      {:ok, _} =
        Accounts.deliver_user_confirmation_instructions(
          user,
          &url(~p"/api/v1/users/confirm/#{&1}")
        )

      render(conn, :show, user: user)
    end
  end
end
