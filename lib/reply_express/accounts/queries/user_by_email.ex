defmodule ReplyExpress.Accounts.Queries.UserByEmail do
  @moduledoc """
  Query module to read a user projection by the user's email
  """

  import Ecto.Query

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @doc """
  Creates new query for a user by the user's email
  """
  def new(email) do
    UserProjection |> where([u], u.email == ^email)
  end
end
