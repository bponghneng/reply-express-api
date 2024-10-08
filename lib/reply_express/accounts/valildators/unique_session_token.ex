defmodule ReplyExpress.Accounts.Validators.UniqueSessionToken do
  @moduledoc """
  Custom Vex.Validator to validate that a session token does not exist for a user uuid
  """

  use Vex.Validator

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UserTokensContext

  @doc """
  Returns an error tuple with message if a user session token exists for the uuid and `:ok` if not
  """
  def validate(value, _context) do
    case session_token_exists?(value) do
      true -> {:error, "session token already exists"}
      false -> :ok
    end
  end

  defp session_token_exists?(uuid) do
    case UserTokensContext.user_session_token_by_user_uuid(uuid) do
      %UserTokenProjection{} -> true
      nil -> false
      _ -> true
    end
  end
end
