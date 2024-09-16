defmodule ReplyExpress.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias ReplyExpress.Repo
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Queries.UserByEmail
  alias ReplyExpress.Accounts.Queries.UserByUUID
  alias ReplyExpress.UserTokens
  alias ReplyExpress.Commanded

  @doc """
  Authenticates a user.
  """
  def log_in_user(attrs) do
    log_in_user =
      attrs
      |> LogInUser.new()
      |> LogInUser.set_logged_in_at()
      |> LogInUser.set_uuid()

    uuid = UUID.uuid4()

    start_user_session =
      log_in_user
      |> Map.from_struct()
      |> Map.take([:logged_in_at])
      |> StartUserSession.new()
      |> StartUserSession.assign_uuid(uuid)
      |> StartUserSession.build_session_token()
      |> StartUserSession.set_user_uuid(log_in_user.uuid)

    with :ok <- Commanded.dispatch(log_in_user, consistency: :strong),
         :ok <- Commanded.dispatch(start_user_session, consistency: :strong) do
      case UserTokens.user_token_by_user_uuid(log_in_user.uuid) do
        nil ->
          {:error, :not_found}

        projection ->
          {:ok, projection}
      end
    end
  end

  @doc """
  Registers a user.
  """
  def register_user(attrs) do
    uuid = UUID.uuid4()

    register_user =
      attrs
      |> RegisterUser.new()
      |> RegisterUser.assign_uuid(uuid)
      |> RegisterUser.downcase_email()
      |> RegisterUser.hash_password()

    with :ok <- Commanded.dispatch(register_user, consistency: :strong) do
      case user_by_uuid(uuid) do
        nil ->
          {:error, :not_found}

        projection ->
          {:ok, projection}
      end
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

  @doc """
  Get an existing user by UUID, or return `nil` if not found
  """
  def user_by_uuid(uuid) when is_binary(uuid) do
    uuid
    |> UserByUUID.new()
    |> Repo.one()
  end
end
