defmodule ReplyExpress.Accounts.Queries.UserTokenByUUID do
  @moduledoc """
  Query module to read a user token projection by the user's UUID
  """

  import Ecto.Query

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @doc """
  Creates new query for a user by the user's UUID
  """
  def new(uuid) do
    UserTokenProjection |> where([u], u.user_uuid == ^uuid)
  end
end
