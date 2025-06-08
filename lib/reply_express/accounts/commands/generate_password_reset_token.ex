defmodule ReplyExpress.Accounts.Commands.GeneratePasswordResetToken do
  @moduledoc """
  Command to log in a registered user, including sanitization and validation fns
  """

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.UsersContext

  @type t :: %__MODULE__{
    email: String.t(),
    token: String.t() | nil,
    user_id: String.t(),
    user_uuid: String.t(),
    uuid: String.t()
  }

  @rand_size 32

  defstruct email: "",
            token: nil,
            user_id: "",
            user_uuid: "",
            uuid: ""

  @doc """
  Assign a unique identity for the user token
  """
  def assign_uuid(%GeneratePasswordResetToken{} = send_password_reset_token, uuid) do
    %GeneratePasswordResetToken{send_password_reset_token | uuid: uuid}
  end

  @doc """
  Generate and encode a token
  """
  def build_reset_password_token(%GeneratePasswordResetToken{} = send_password_reset_token) do
    token =
      @rand_size
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    %GeneratePasswordResetToken{send_password_reset_token | token: token}
  end

  @doc """
  Set full_name and user_uuid from the user
  """
  def set_user_properties(%GeneratePasswordResetToken{} = send_password_reset_token) do
    user_projection = extract_user_projection(send_password_reset_token)

    %GeneratePasswordResetToken{
      send_password_reset_token
      | user_id: user_projection.id,
        user_uuid: user_projection.uuid
    }
  end

  defp extract_user_projection(%GeneratePasswordResetToken{} = send_password_reset_token) do
    UsersContext.user_by_email(send_password_reset_token.email)
  end
end
