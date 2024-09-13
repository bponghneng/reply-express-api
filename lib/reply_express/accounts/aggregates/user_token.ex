defmodule ReplyExpress.Accounts.Aggregates.UserToken do
  @moduledoc """
  Command handler for the user token aggregate
  """

  alias ReplyExpress.Accounts.Aggregates.UserToken
  alias ReplyExpress.Accounts.Events.UserSessionTokenCreated

  defstruct [
    :context,
    :sent_to,
    :token,
    :user_uuid,
    :uuid
  ]

  # Mutators
  def apply(%UserToken{} = user_token, %UserSessionTokenCreated{} = created_user_token) do
    %UserToken{
      user_token
      | context: created_user_token.context,
        token: created_user_token.token,
        user_uuid: created_user_token.user_uuid,
        uuid: created_user_token.uuid
    }
  end
end
