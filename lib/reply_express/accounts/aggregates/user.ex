defmodule ReplyExpress.Accounts.Aggregates.User do
  @moduledoc """
  Command handler for the user account aggregate
  """

  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword

  alias ReplyExpress.Accounts.Events.PasswordReset
  alias ReplyExpress.Accounts.Events.UserCreated
  alias ReplyExpress.Accounts.Events.UserLoggedIn
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Events.UserTokensCleared

  @type t :: %__MODULE__{
          email: String.t() | nil,
          hashed_password: String.t() | nil,
          logged_in_at: DateTime.t() | nil,
          uuid: String.t() | nil
        }

  defstruct [:email, :hashed_password, :logged_in_at, :uuid]

  @spec execute(
          t(),
          ClearUserTokens.t() | CreateUser.t() | Login.t() | RegisterUser.t() | ResetPassword.t()
        ) ::
          UserTokensCleared.t()
          | UserCreated.t()
          | UserLoggedIn.t()
          | UserRegistered.t()
          | PasswordReset.t()

  def execute(%__MODULE__{}, %ClearUserTokens{} = clear_user_tokens) do
    %UserTokensCleared{uuid: clear_user_tokens.uuid}
  end

  def execute(%__MODULE__{uuid: nil}, %CreateUser{} = create_user) do
    %UserCreated{
      uuid: create_user.uuid,
      email: create_user.email,
      hashed_password: create_user.hashed_password
    }
  end

  def execute(%__MODULE__{uuid: uuid, email: email}, %Login{} = login) do
    %UserLoggedIn{
      email: email,
      logged_in_at: login.logged_in_at,
      uuid: uuid
    }
  end

  def execute(%__MODULE__{uuid: nil}, %RegisterUser{} = register) do
    %UserRegistered{
      uuid: register.uuid,
      email: register.email,
      hashed_password: register.hashed_password
    }
  end

  def execute(%__MODULE__{uuid: uuid}, %ResetPassword{} = reset_password) do
    %PasswordReset{hashed_password: reset_password.hashed_password, uuid: uuid}
  end

  # Mutators
  @spec apply(
          t(),
          UserCreated.t() | UserLoggedIn.t() | UserRegistered.t() | PasswordReset.t() | any()
        ) :: t()

  def apply(%__MODULE__{} = user, %UserLoggedIn{} = logged_in) do
    %__MODULE__{user | logged_in_at: logged_in.logged_in_at, uuid: logged_in.uuid}
  end

  def apply(%__MODULE__{} = user, event) when event.__struct__ in [UserCreated, UserRegistered] do
    %__MODULE__{
      user
      | uuid: event.uuid,
        email: event.email,
        hashed_password: event.hashed_password
    }
  end

  def apply(%__MODULE__{} = user, %PasswordReset{} = reset) do
    %__MODULE__{user | hashed_password: reset.hashed_password, uuid: user.uuid}
  end

  def apply(%__MODULE__{} = user, _event), do: user
end
