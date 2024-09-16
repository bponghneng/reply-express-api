defmodule ReplyExpressWeb.API.V1.Users.ResetPasswordJSON do
  @moduledoc """
  Renders public state of user after initial registration
  """
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @doc """
  Renders a single user's registration details.
  """
  def show(%{token: token}) do
    %{data: data(token)}
  end

  defp data(%UserTokenProjection{} = user_token_projection) do
    %{context: user_token_projection.context, token: Base.encode64(user_token_projection.token)}
  end
end
