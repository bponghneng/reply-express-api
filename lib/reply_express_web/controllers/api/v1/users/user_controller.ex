defmodule ReplyExpressWeb.API.V1.Users.UserController do
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext
  alias ReplyExpressWeb.API.V1.Users.UserJSON

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  @doc """
  Handles user creation.

  - If the request body contains a "user" param, attempts to create the user and returns the result.
  - If the "user" param is missing or empty, returns a 422 error with a message that "user" is required.
  """
  def create(conn, %{"user" => user_params}) when is_map(user_params) do
    result = UsersContext.create_user(user_params)

    with {:ok, %UserProjection{} = user} <- result do
      conn
      |> put_status(:created)
      |> put_view(UserJSON)
      |> render(:show, user: user)
    end
  end

  def create(conn, _params) do
    errors = %{"user" => ["is required"]}

    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"errors" => errors})
  end
end
