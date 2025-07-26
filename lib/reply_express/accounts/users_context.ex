defmodule ReplyExpress.Accounts.UsersContext do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Queries.UserByEmail
  alias ReplyExpress.Accounts.Queries.UserByUUID
  alias ReplyExpress.Accounts.UserTokensContext
  alias ReplyExpress.Commanded
  alias ReplyExpress.Repo

  @doc """
  Sets a reset_password token for a user
  """
  def generate_password_reset_token(attrs) do
    uuid = UUID.uuid4()

    send_password_reset_token =
      attrs
      |> GeneratePasswordResetToken.new()
      |> GeneratePasswordResetToken.assign_uuid(uuid)
      |> GeneratePasswordResetToken.build_reset_password_token()
      |> GeneratePasswordResetToken.set_user_properties()

    clear_user_tokens =
      send_password_reset_token
      |> Map.from_struct()
      |> Map.take([:user_uuid])
      |> Map.put(:uuid, send_password_reset_token.user_uuid)
      |> ClearUserTokens.new()

    with :ok <- Commanded.dispatch(clear_user_tokens),
         :ok <- Commanded.dispatch(send_password_reset_token, consistency: :strong) do
      case UserTokensContext.user_reset_password_token_by_user_uuid(
             send_password_reset_token.user_uuid
           ) do
        nil ->
          {:error, :not_found}

        projection ->
          {:ok, projection}
      end
    end
  end

  @doc """
  Authenticates a user.
  """
  def login(attrs) do
    login_command = build_login_command(attrs)

    with :ok <- Commanded.dispatch(login_command, consistency: :strong),
         :ok <- clear_existing_session(login_command),
         :ok <- command_start_user_session(login_command) do
      case UserTokensContext.user_session_token_by_user_uuid(login_command.uuid) do
        nil ->
          {:error, :not_found}

        projection ->
          {:ok, projection}
      end
    end
  end

  defp build_login_command(attrs) do
    attrs
    |> Login.new()
    |> Login.set_logged_in_at()
    |> Login.set_id_and_uuid()
  end

  defp clear_existing_session(login_command) do
    clear_user_tokens =
      login_command
      |> Map.from_struct()
      |> Map.take([:uuid])
      |> ClearUserTokens.new()

    Commanded.dispatch(clear_user_tokens, consistency: :strong)
  end

  defp command_start_user_session(login_command) do
    uuid = UUID.uuid4()

    login_command
    |> Map.from_struct()
    |> Map.take([:logged_in_at])
    |> StartUserSession.new()
    |> StartUserSession.assign_uuid(uuid)
    |> StartUserSession.build_session_token()
    |> StartUserSession.set_user_id(login_command.id)
    |> StartUserSession.set_user_uuid(login_command.uuid)
    |> Commanded.dispatch(consistency: :strong)
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

  @spec create_user(map()) ::
          {:ok, ReplyExpress.Accounts.Projections.User.t()}
          | {:error, :validation_failure, map()}
          | {:error, atom()}
  @doc """
  Creates a user with the given attributes.

  This function creates a user without triggering the team creation workflow
  that happens during registration. It's intended for administrative user creation
  or simplified user creation scenarios.

  ## Parameters
    - attrs: A map containing:
      - email: The user's email address
      - password: The user's password

  ## Returns
    - `{:ok, user}` - Returns the created user if successful
    - `{:error, :validation_failure, errors}` - Returns validation errors if unsuccessful
    - `{:error, reason}` - Returns other errors that may occur
  """
  def create_user(attrs) do
    uuid = UUID.uuid4()

    create_user =
      attrs
      |> CreateUser.new()
      |> CreateUser.set_uuid(uuid)
      |> CreateUser.downcase_email()
      |> CreateUser.hash_password()

    with :ok <- Commanded.dispatch(create_user, consistency: :strong) do
      case user_by_uuid(uuid) do
        nil ->
          {:error, :not_found}

        projection ->
          {:ok, projection}
      end
    end
  end

  def reset_password(attrs) do
    reset_password =
      attrs
      |> ResetPassword.new()
      |> ResetPassword.hash_password()
      |> ResetPassword.set_uuid_from_token()

    clear_user_tokens =
      reset_password
      |> Map.take([:uuid])
      |> ClearUserTokens.new()

    with :ok <- Commanded.dispatch(reset_password),
         :ok <- Commanded.dispatch(clear_user_tokens, consistency: :strong) do
      {:ok, reset_password}
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
