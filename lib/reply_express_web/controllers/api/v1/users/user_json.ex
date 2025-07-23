defmodule ReplyExpressWeb.API.V1.Users.UserJSON do
  @moduledoc """
  Renders user data for API responses.
  Used for both user registration and user creation endpoints.
  """

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @doc """
  Renders a single user's details.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%UserProjection{} = user) do
    %{
      confirmed_at: user.confirmed_at,
      email: user.email,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at,
      uuid: user.uuid
    }
  end
end
