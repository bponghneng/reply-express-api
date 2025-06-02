defmodule ReplyExpress.Accounts.Aggregates.User do
  @moduledoc """
  Command handler for the user account aggregate
  """

  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword

  alias ReplyExpress.Accounts.Events.PasswordReset
  alias ReplyExpress.Accounts.Events.UserLoggedIn
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Events.UserTokensCleared

  defstruct [:email, :hashed_password, :logged_in_at, :uuid]

  def execute(%User{}, %ClearUserTokens{} = clear_user_tokens) do
    %UserTokensCleared{uuid: clear_user_tokens.uuid}
  end

  def execute(%User{uuid: uuid, email: email}, %LogInUser{} = login) do
    %UserLoggedIn{
      email: email,
      logged_in_at: login.logged_in_at,
      uuid: uuid
    }
  end

  def execute(%User{uuid: nil}, %RegisterUser{} = register) do
    %UserRegistered{
      uuid: register.uuid,
      email: register.email,
      hashed_password: register.hashed_password
    }
  end

  def execute(%User{uuid: uuid}, %ResetPassword{} = reset_password) do
    %PasswordReset{hashed_password: reset_password.hashed_password, uuid: uuid}
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

  def apply(%User{} = user, %PasswordReset{} = reset) do
    %User{user | hashed_password: reset.hashed_password, uuid: user.uuid}
  end

  def apply(%User{} = user, _event), do: user
end
