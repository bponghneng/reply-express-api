defmodule ReplyExpressWeb.API.V1.Users.ChangePasswordController do
  @moduledoc """
  Controller for handling password change requests
  """
  use ReplyExpressWeb, :controller

  alias ReplyExpress.Accounts.UsersContext

  action_fallback ReplyExpressWeb.API.V1.FallbackController

  def create(conn, params) do
    with {:ok, _result} <- UsersContext.reset_password(params) do
      send_resp(conn, 204, "")
    end
  end
end
