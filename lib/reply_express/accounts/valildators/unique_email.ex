defmodule ReplyExpress.Accounts.Validators.UniqueEmail do
  @moduledoc """
  Custom Vex.Validator to validate that an email in a new user registration is unique
  """

  use Vex.Validator

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext

  @doc """
  Returns an error tuple with message if a user registration exists for the email and `:ok` if not
  """
  def validate(value, _context) do
    case email_registered?(value) do
      true -> {:error, "has already been taken"}
      false -> :ok
    end
  end

  defp email_registered?(email) do
    case UsersContext.user_by_email(email) do
      %UserProjection{} -> true
      nil -> false
      _ -> true
    end
  end
end
