defmodule ReplyExpress.Accounts.Commands.CreateUserSessionToken do
  @moduledoc """
  Command to create a session token for a logged in user, including sanitization and validation fns
  """

  defstruct context: "session",
            token: nil,
            logged_in_at: nil,
            user_uuid: "",
            uuid: ""

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.CreateUserSessionToken
  alias ReplyExpress.Accounts.Validators.UniqueSessionToken
  alias ReplyExpress.Accounts.Validators.LoggedInAtNotExpired

  @rand_size 32

  validates(:context, presence: [message: "can't be empty"], inclusion: ["session"])

  validates(:logged_in_at,
    presence: [message: "can't be empty"],
    by: &LoggedInAtNotExpired.validate/2
  )

  validates(:token, presence: [message: "can't be empty"])
  validates(:user_uuid, presence: [message: "can't be empty"], by: &UniqueSessionToken.validate/2)

  @doc """
  Assign a unique identity for the user token.
  """
  def assign_uuid(%CreateUserSessionToken{} = create_user_session_token, uuid) do
    %CreateUserSessionToken{create_user_session_token | uuid: uuid}
  end

  def build_session_token(%CreateUserSessionToken{} = create_user_session_token) do
    token =
      @rand_size
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    %CreateUserSessionToken{create_user_session_token | token: token}
  end

  def set_user_uuid(%CreateUserSessionToken{} = create_user_session_token, user_uuid) do
    %CreateUserSessionToken{create_user_session_token | user_uuid: user_uuid}
  end
end
