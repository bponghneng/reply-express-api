defmodule ReplyExpress.Accounts.Commands.RegisterUser do
  @moduledoc """
  Command for registering a new user, including sanitization and validation fns
  """

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Validators.UniqueEmail
  alias Vex.ErrorRenderers.Parameterized

  @type t :: %__MODULE__{
          email: String.t(),
          hashed_password: String.t(),
          password: String.t(),
          uuid: String.t()
        }

  defstruct email: "",
            hashed_password: "",
            password: "",
            uuid: ""

  validates(:email,
    presence: [message: "can't be empty"],
    format: [with: ~r/\S+@\S+\.\S+/, message: "is invalid"],
    by: &UniqueEmail.validate/2
  )

  validates(:password,
    presence: [message: "can't be empty"],
    length: [
      min: 8,
      message: "must be at least 8 characters",
      error_renderer: Parameterized
    ]
  )

  validates(:uuid, uuid: true)

  @doc """
  Assign a unique identity for the user.
  """
  def assign_uuid(%RegisterUser{} = register_user, uuid) do
    %RegisterUser{register_user | uuid: uuid}
  end

  @doc """
  Convert email address to lowercase characters
  """
  def downcase_email(%RegisterUser{email: email} = register_user) do
    %RegisterUser{register_user | email: String.downcase(email)}
  end

  @doc """
  Hash the password and preserve the original password
  """
  def hash_password(%RegisterUser{password: password} = register_user) do
    %RegisterUser{
      register_user
      | hashed_password: Pbkdf2.hash_pwd_salt(password)
    }
  end
end
