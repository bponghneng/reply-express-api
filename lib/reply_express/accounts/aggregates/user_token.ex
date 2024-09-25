defmodule ReplyExpress.Accounts.Aggregates.UserToken do
  @moduledoc """
  Command handler for the user token aggregate
  """

  alias ReplyExpress.Accounts.Aggregates.UserToken
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Events.PasswordResetTokenGenerated
  alias ReplyExpress.Accounts.Events.UserSessionStarted

  defstruct [
    :context,
    :sent_to,
    :token,
    :user_id,
    :user_uuid,
    :uuid
  ]

  def execute(%UserToken{uuid: nil}, %GeneratePasswordResetToken{} = reset_token) do
    %PasswordResetTokenGenerated{
      email: reset_token.email,
      token: reset_token.token,
      user_id: reset_token.user_id,
      user_uuid: reset_token.user_uuid,
      uuid: reset_token.uuid
    }
  end

  def execute(%UserToken{uuid: nil}, %StartUserSession{} = user_session) do
    %UserSessionStarted{
      context: user_session.context,
      token: user_session.token,
      user_id: user_session.user_id,
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

  def apply(%UserToken{} = user_token, %PasswordResetTokenGenerated{} = reset_token) do
    %UserToken{
      user_token
      | context: "reset_password",
        sent_to: reset_token.email,
        token: reset_token.token,
        user_id: reset_token.user_id,
        user_uuid: reset_token.user_uuid,
        uuid: reset_token.uuid
    }
  end
end
