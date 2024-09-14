defmodule ReplyExpress.Accounts.Validators.ValidCredentials do
  @moduledoc """
  Custom Vex.Validator to validate that an email and password represent a registered user
  """

  use Vex.Validator

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  @doc """
  Returns an error tuple with message if a user registration does not exist or if the password
  does not validate against the user's hashed_password
  """
  def validate(value, _context) do
    value.email
    |> Accounts.user_by_email()
    |> password_matches?(value.password)
    |> case do
      true -> :ok
      _ -> {:error, "are invalid"}
    end
  end

  defp password_matches?(%UserProjection{} = user_projection, password) do
    Pbkdf2.verify_pass(password, user_projection.hashed_password)
  end

  defp password_matches?(_, _), do: nil
end
