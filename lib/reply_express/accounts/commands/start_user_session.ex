defmodule ReplyExpress.Accounts.Commands.StartUserSession do
  @moduledoc """
  Command to start a session for a logged in user, including sanitization and validation fns
  """

  defstruct context: "session",
            token: nil,
            logged_in_at: nil,
            user_id: nil,
            user_uuid: "",
            uuid: ""

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.StartUserSession
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
  def assign_uuid(%StartUserSession{} = start_user_session, uuid) do
    %StartUserSession{start_user_session | uuid: uuid}
  end

  def build_session_token(%StartUserSession{} = start_user_session) do
    token =
      @rand_size
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    %StartUserSession{start_user_session | token: token}
  end

  def set_user_uuid(%StartUserSession{} = start_user_session, user_uuid) do
    %StartUserSession{start_user_session | user_uuid: user_uuid}
  end
end
