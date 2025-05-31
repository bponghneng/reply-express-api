defmodule ReplyExpressWeb.API.V1.Users.RegistrationController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  @spec create(any(), any()) :: {:error, any()} | {:ok, any()} | Plug.Conn.t()
  @doc """
  Handles user registration.

  - If the request body contains a "user" param, attempts to register the user and returns the result.
  - If the "user" param is missing or empty, returns a 422 error with a message that "user" is required.
  """
  def create(conn, %{"user" => user_params})
      when is_map(user_params) and map_size(user_params) > 0 do
    result = UsersContext.register_user(user_params)

    with {:ok, %UserProjection{} = user} <- result do
      render(conn, :show, user: user)
    end
  end

  def create(conn, _params) do
    errors = %{"user" => ["is required"]}

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"errors" => errors})
  end
end
