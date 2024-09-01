defmodule ReplyExpress.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias ReplyExpress.Repo
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Queries.UserByEmail
  alias ReplyExpress.Commanded

  @doc """
  Registers a user.
  """
  def register_user(attrs) do
    uuid = Ecto.UUID.generate()

    register_user =
      attrs
      |> RegisterUser.new()
      |> RegisterUser.assign_uuid(uuid)
      |> RegisterUser.downcase_email()
      |> RegisterUser.hash_password()

    with {:ok, validated} <- validate_command(register_user),
         {:ok, _} <- dispatch_command(validated) do
      get(UserProjection, uuid)
    end
  end

  def get(schema, uuid) do
    case Repo.get(schema, uuid) do
      nil ->
        {:error, :not_found}

      projection ->
        {:ok, projection}
    end
  end

  @doc """
  Get an existing user by email address, or return `nil` if not registered
  """
  def user_by_email(email) when is_binary(email) do
    email
    |> String.downcase()
    |> UserByEmail.new()
    |> Repo.one()
  end

  defp validate_command(command) do
    case Vex.errors(command) do
      [] -> {:ok, command}
      error -> {:command_validation_error, error}
    end
  end

  defp dispatch_command(command) do
    case Commanded.dispatch(command, consistency: :strong) do
      :ok -> {:ok, []}
      error -> {:command_dispatch_error, error}
    end
  end
end
