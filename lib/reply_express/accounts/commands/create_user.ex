defmodule ReplyExpress.Accounts.Commands.CreateUser do
  @moduledoc """
  Command for creating a user (distinct from user registration).

  This command creates a user without triggering the automatic team creation
  process that happens during registration. It's intended for scenarios
  where you want to create a user without the full registration workflow.
  """

  use ExConstructor
  use Vex.Struct

  @type t :: %__MODULE__{
          uuid: String.t(),
          email: String.t(),
          hashed_password: String.t()
        }

  defstruct [:uuid, :email, :hashed_password]

  validates(:uuid, presence: [message: "can't be empty"])
  validates(:email, presence: [message: "can't be empty"])
  validates(:hashed_password, presence: [message: "can't be empty"])

  @doc """
  Sets the UUID for the user.
  """
  def set_uuid(%__MODULE__{} = command, uuid) do
    %{command | uuid: uuid}
  end

  @doc """
  Sets the email for the user.
  """
  def set_email(%__MODULE__{} = command, email) do
    %{command | email: email}
  end

  @doc """
  Sets the hashed password for the user.
  """
  def set_hashed_password(%__MODULE__{} = command, hashed_password) do
    %{command | hashed_password: hashed_password}
  end
end
