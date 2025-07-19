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
  def validate(value, _context) when is_nil(value) or value == "" do
    {:error, "is invalid"}
  end

  def validate(value, _context) when is_binary(value) do
    value
    |> UsersContext.user_by_uuid()
    |> case do
      %UserProjection{} -> :ok
      _ -> {:error, "is invalid"}
    end
  end

  def validate(_value, _context) do
    {:error, "is invalid"}
  end
end
