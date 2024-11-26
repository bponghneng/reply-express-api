defmodule ReplyExpress.Accounts.Validators.ResetPasswordTokenExists do
  @moduledoc """
  Custom Vex.Validator to validate that a reset password token exists
  """

  use Vex.Validator

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UserTokensContext

  @doc """
  Returns an error tuple with message if a user session token exists for the uuid and `:ok` if not
  """
  def validate(value, _context) do
    if is_nil(value), do: :ok, else: validate_exists(value)
  end

  defp validate_exists(value) do
    case reset_password_token_exists?(value) do
      true -> :ok
      false -> {:error, "invalid token"}
    end
  end

  defp reset_password_token_exists?(token) do
    case UserTokensContext.user_reset_password_token_by_token(token) do
      %UserTokenProjection{} -> true
      _ -> false
    end
  end
end
