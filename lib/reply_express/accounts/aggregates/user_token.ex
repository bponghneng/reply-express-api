defmodule ReplyExpress.Accounts.Aggregates.UserToken do
  @moduledoc """
  Command handler for the user token aggregate
  """

  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Events.PasswordResetTokenGenerated
  alias ReplyExpress.Accounts.Events.UserSessionStarted

  @type t :: %__MODULE__{
          context: String.t(),
          sent_to: String.t(),
          token: String.t(),
          user_id: integer,
          user_uuid: String.t(),
          uuid: String.t()
        }

  defstruct [
    :context,
    :sent_to,
    :token,
    :user_id,
    :user_uuid,
    :uuid
  ]

  @spec execute(
          t(),
          GeneratePasswordResetToken.t() | StartUserSession.t()
        ) :: PasswordResetTokenGenerated.t() | UserSessionStarted.t()

  def execute(%__MODULE__{uuid: nil}, %GeneratePasswordResetToken{} = reset_token) do
    %PasswordResetTokenGenerated{
      email: reset_token.email,
      token: reset_token.token,
      user_id: reset_token.user_id,
      user_uuid: reset_token.user_uuid,
      uuid: reset_token.uuid
    }
  end

  def execute(%__MODULE__{uuid: nil}, %StartUserSession{} = user_session) do
    %UserSessionStarted{
      context: user_session.context,
      token: user_session.token,
      user_id: user_session.user_id,
      user_uuid: user_session.user_uuid,
      uuid: user_session.uuid
    }
  end

  # Mutators
  @spec apply(
          t(),
          UserSessionStarted.t() | PasswordResetTokenGenerated.t() | any()
        ) :: t()

  def apply(%__MODULE__{} = user_token, %UserSessionStarted{} = user_session) do
    %__MODULE__{
      user_token
      | context: user_session.context,
        token: user_session.token,
        user_uuid: user_session.user_uuid,
        uuid: user_session.uuid
    }
  end

  def apply(%__MODULE__{} = user_token, %PasswordResetTokenGenerated{} = reset_token) do
    %__MODULE__{
      user_token
      | context: "reset_password",
        sent_to: reset_token.email,
        token: reset_token.token,
        user_id: reset_token.user_id,
        user_uuid: reset_token.user_uuid,
        uuid: reset_token.uuid
    }
  end

  def apply(%__MODULE__{} = user_token, _event), do: user_token
end
