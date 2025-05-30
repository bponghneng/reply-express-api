defmodule ReplyExpressWeb.API.V1.Users.SessionController do
  use ReplyExpressWeb, :controller

  alias Plug.Conn
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UsersContext

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()

  @doc """
  Handles login requests with credentials.
  """
  def create(conn, %{"credentials" => credentials}) do
    result =
      UsersContext.log_in_user(%{
        credentials: %{email: credentials["email"], password: credentials["password"]}
      })

    with {:ok, %UserTokenProjection{} = user_token_projection} <- result do
      conn
      |> Conn.put_resp_cookie(user_token_projection.context, user_token_projection.token,
        encrypt: true
      )
      |> put_status(:no_content)
      |> json(%{})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"errors" => %{"credentials" => ["is required"]}})
  end
end
