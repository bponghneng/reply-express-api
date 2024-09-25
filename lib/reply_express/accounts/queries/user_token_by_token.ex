defmodule ReplyExpress.Accounts.Queries.UserTokenByToken do
  @moduledoc """
  Query module to read a user token projection by the token
  """

  import Ecto.Query

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @doc """
  Retrieve user token projection by the token
  """
  def new(token) do
    binary_token = Base.decode64!(token)

    UserTokenProjection |> where([ut], ut.token == ^binary_token)
  end
end
