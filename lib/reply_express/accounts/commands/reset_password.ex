defmodule ReplyExpress.Accounts.Commands.ResetPassword do
  @moduledoc """
  Command to reset a user's password
  """

  defstruct hashed_password: "",
            password: "",
            password_confirmation: "",
            token: nil,
            uuid: ""

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.ResetPassword
  #  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.Validators.ResetPasswordTokenExists
  alias ReplyExpress.Accounts.UserTokensContext

  validates(:password,
    presence: [message: "can't be empty"],
    confirmation: [message: "passwords do not match"]
  )

  validates(:token,
    presence: [message: "can't be empty"],
    by: &ResetPasswordTokenExists.validate/2
  )

  @doc """
  Hash the password and preserve the original password
  """
  def hash_password(%ResetPassword{password: password} = reset_password) do
    %ResetPassword{
      reset_password
      | hashed_password: Pbkdf2.hash_pwd_salt(password)
    }
  end

  @doc """
  Looks up the reset password token for the user and sets the uuid
  """
  def set_uuid_from_token(%ResetPassword{token: token} = reset_password) do
    user_token =
      if is_nil(token), do: nil, else: UserTokensContext.user_reset_password_token_by_token(token)

    uuid = if is_nil(user_token), do: nil, else: user_token |> Map.get(:user) |> Map.get(:uuid)

    %ResetPassword{reset_password | uuid: uuid}
  end

  @doc """
  Looks up the reset password token for the user and sets the uuid (compatibility for change_password/1)
  """
  def set_user_properties(%ResetPassword{token: token} = reset_password) do
    user_token =
      if is_nil(token), do: nil, else: UserTokensContext.user_reset_password_token_by_token(token)

    uuid = if is_nil(user_token), do: nil, else: user_token |> Map.get(:user) |> Map.get(:uuid)

    %ResetPassword{reset_password | uuid: uuid}
  end
end
