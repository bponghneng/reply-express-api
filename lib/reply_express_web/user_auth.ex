defmodule ReplyExpressWeb.UserAuth do
  use ReplyExpressWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.UserTokens

  @doc """
  Logs the user in.
  """
  def log_in_user(conn, user) do
    case UserTokens.get_session_tokens_by_user(user) do
      [] ->
        bearer_token =
          user
          |> Accounts.generate_user_session_token()
          |> Base.url_encode64(padding: false)

        json(conn, %{data: %{token: bearer_token}})

      _ ->
        send_resp(conn, 403, "")
    end
  end

  @doc """
  Logs the user out.
  """
  def log_out_user(conn) do
    Accounts.delete_user_session_tokens(conn.assigns[:current_user])

    send_resp(conn, 204, "")
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def forbid_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user], do: send_resp(conn, 401, ""), else: conn
  end

  @doc """
  Used for routes that require the user to be authenticated.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.assigns[:current_user], do: conn, else: send_resp(conn, 401, "")
  end

  @doc """
  Authenticates the user by extracting bearer token.
  """
  def fetch_current_user(conn, _opts) do
    {user_token, conn} = ensure_user_token(conn)
    user = user_token && Accounts.get_user_by_session_token(user_token)
    assign(conn, :current_user, user)
  end

  defp ensure_user_token(conn) do
    {:ok, token} =
      conn
      |> get_req_header("authorization")
      |> Enum.reduce({:ok, nil}, fn
        "Bearer " <> token, _acc -> Base.url_decode64(token, padding: false)
        _, acc -> acc
      end)

    {token, conn}
  end
end
