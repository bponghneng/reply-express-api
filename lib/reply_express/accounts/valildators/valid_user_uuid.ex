defmodule ReplyExpress.Accounts.Validators.ValidUserUUID do
  @moduledoc """
  Custom Vex.Validator to validate that a uuid represents a registered user
  """

  use Vex.Validator

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext

  @doc """
  Returns an error tuple with message if a user does not exist
  """
  def validate(value, _context) do
    value
    |> UsersContext.user_by_uuid()
    |> case do
      %UserProjection{} -> :ok
      _ -> {:error, "is invalid"}
    end
  end
end
