defmodule ReplyExpressWeb.API.V1.UserRegistrationJSON do
  alias ReplyExpress.Accounts.User

  @doc """
  Renders a single user account.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{
      confirmed_at: user.confirmed_at,
      email: user.email,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at,
      uuid: user.uuid
    }
  end
end
