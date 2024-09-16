defmodule ReplyExpress.Accounts.Aggregates.UserToken do
  @moduledoc """
  Command handler for the user token aggregate
  """

  alias ReplyExpress.Accounts.Aggregates.UserToken
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Events.PasswordResetTokenSent
  alias ReplyExpress.Accounts.Events.UserSessionStarted

  defstruct [
    :context,
    :sent_to,
    :token,
    :user_uuid,
    :uuid
  ]

  def execute(%UserToken{uuid: nil}, %StartUserSession{} = user_session) do
    %UserSessionStarted{
      context: user_session.context,
      token: user_session.token,
      user_uuid: user_session.user_uuid,
      uuid: user_session.uuid
    }
  end

  # Mutators
  def apply(%UserToken{} = user_token, %UserSessionStarted{} = user_session) do
    %UserToken{
      user_token
      | context: user_session.context,
        token: user_session.token,
        user_uuid: user_session.user_uuid,
        uuid: user_session.uuid
    }
  end
end
