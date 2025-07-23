defmodule ReplyExpress.Accounts.Commands.CreateUser do
  @moduledoc """
  Command for creating a user (distinct from user registration).

  This command creates a user without triggering the automatic team creation
  process that happens during registration. It's intended for scenarios
  where you want to create a user without the full registration workflow.
  """

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Validators.UniqueEmail
  alias Vex.ErrorRenderers.Parameterized

  @type t :: %__MODULE__{
          uuid: String.t(),
          email: String.t(),
          password: String.t() | nil,
          hashed_password: String.t()
        }

  defstruct [
    :uuid,
    :email,
    :password,
    :hashed_password
  ]

  validates(:uuid, presence: [message: "can't be empty"])

  validates(:email,
    presence: [message: "can't be empty"],
    format: [with: ~r/\S+@\S+\.\S+/, message: "is invalid"],
    by: &UniqueEmail.validate/2
  )

  validates(:hashed_password, presence: [message: "can't be empty"])
  # Only validate password if it's provided
  validates(:password,
    length: [
      min: 8,
      message: "must be at least 8 characters",
      error_renderer: Parameterized,
      allow_nil: true
    ]
  )

  @doc """
  Sets the UUID for the user.
  """
  def set_uuid(%CreateUser{} = command, uuid) do
    %{command | uuid: uuid}
  end

  @doc """
  Convert email address to lowercase characters
  """
  def downcase_email(%CreateUser{email: email} = command) do
    %CreateUser{command | email: String.downcase(email)}
  end

  @doc """
  Hash the password and preserve the original password.
  Only hashes if password is present, otherwise leaves hashed_password unchanged.
  """
  def hash_password(%CreateUser{password: password} = command)
      when is_binary(password) and password != "" do
    %CreateUser{
      command
      | hashed_password: Pbkdf2.hash_pwd_salt(password)
    }
  end

  # Skip hashing if no password is provided
  def hash_password(%CreateUser{} = command), do: command

  @doc """
  Sets the hashed password for the user.
  For backwards compatibility with existing code.
  """
  def set_hashed_password(%CreateUser{} = command, hashed_password) do
    %{command | hashed_password: hashed_password}
  end
end
