defmodule ReplyExpress.Accounts.Queries.UserByUUID do
  @moduledoc """
  Query module to read a user projection by the user's UUID
  """

  import Ecto.Query

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @doc """
  Creates new query for a user by the user's UUID
  """
  def new(uuid) do
    UserProjection |> where([u], u.uuid == ^uuid)
  end
end
