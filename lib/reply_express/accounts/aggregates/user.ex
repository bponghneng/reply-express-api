defmodule ReplyExpress.Accounts.Aggregates.User do
  @moduledoc """
  Command handler for the user account aggregate
  """

  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Events.UserRegistered

  defstruct [
    :uuid,
    :email,
    :hashed_password
  ]

  @doc """
  Register a new user
  """
  def execute(%User{uuid: nil}, %RegisterUser{} = register) do
    %UserRegistered{
      uuid: register.uuid,
      email: register.email,
      hashed_password: register.hashed_password
    }
  end

  # Mutators
  @doc """
    UserRegistered: Initial state of user
  """
  def apply(%User{} = user, %UserRegistered{} = registered) do
    %User{
      user
      | uuid: registered.uuid,
        email: registered.email,
        hashed_password: registered.hashed_password
    }
  end
end
