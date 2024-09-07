defmodule ReplyExpress.Accounts.Aggregates.User do
  @moduledoc """
  Command handler for the user account aggregate
  """

  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Commands.CreateUserSessionToken
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Events.UserLoggedIn
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Events.UserSessionTokenCreated

  defstruct [
    :email,
    :hashed_password,
    :logged_in_at,
    :uuid
  ]

  def execute(%User{uuid: nil}, %CreateUserSessionToken{} = create_user_session_token) do
    %UserSessionTokenCreated{
      token: create_user_session_token.token,
      user_uuid: create_user_session_token.user_uuid
    }
  end

  def execute(%User{uuid: nil}, %LogInUser{} = login) do
    %UserLoggedIn{
      credentials: login.credentials,
      logged_in_at: login.logged_in_at,
      uuid: login.uuid
    }
  end

  def execute(%User{uuid: nil}, %RegisterUser{} = register) do
    %UserRegistered{
      uuid: register.uuid,
      email: register.email,
      hashed_password: register.hashed_password
    }
  end

  # Mutators
  def apply(%User{} = user, %UserLoggedIn{} = logged_in) do
    %User{user | logged_in_at: logged_in.logged_in_at, uuid: logged_in.uuid}
  end

  def apply(%User{} = user, %UserRegistered{} = registered) do
    %User{
      user
      | uuid: registered.uuid,
        email: registered.email,
        hashed_password: registered.hashed_password
    }
  end

  def apply(%User{} = user, _event), do: user
end
