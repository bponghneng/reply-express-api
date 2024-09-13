defmodule ReplyExpress.Accounts.Commands.CreateUserSessionToken do
  @moduledoc """
  Command to create a session token for a logged in user, including sanitization and validation fns
  """

  defstruct context: "session",
            token: nil,
            logged_in_at: nil,
            user_uuid: ""

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

  def build_session_token(%CreateUserSessionToken{} = create_user_session_token) do
    IO.inspect(create_user_session_token, label: "create_user_session_token")
    token = :crypto.strong_rand_bytes(@rand_size)

    %CreateUserSessionToken{create_user_session_token | token: token}
  end

  def set_user_uuid(%CreateUserSessionToken{} = create_user_session_token, user_uuid) do
    %CreateUserSessionToken{create_user_session_token | user_uuid: user_uuid}
  end
end
