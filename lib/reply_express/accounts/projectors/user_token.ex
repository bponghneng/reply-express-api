defmodule ReplyExpress.Accounts.Projectors.UserToken do
  @moduledoc """
  Projector extracting user token state from domain events
  """

  use Commanded.Projections.Ecto,
    application: ReplyExpress.Commanded,
    consistency: :strong,
    name: "user_tokens",
    repo: ReplyExpress.Repo

  alias Ecto.Multi
  alias ReplyExpress.Accounts.Events.PasswordResetTokenGenerated
  alias ReplyExpress.Accounts.Events.UserSessionStarted
  alias ReplyExpress.Accounts.Events.UserTokensCleared
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.Queries.UserTokenByUUID

  project(%PasswordResetTokenGenerated{} = reset_token, _metadata, fn multi ->
    token = reset_token.token |> Base.decode64!()

    Multi.insert(multi, :user_tokens, %UserTokenProjection{
      context: "reset_password",
      sent_to: reset_token.email,
      token: token,
      user_id: reset_token.user_id,
      user_uuid: reset_token.user_uuid,
      uuid: reset_token.uuid
    })
  end)

  project(%UserSessionStarted{} = user_session, _metadata, fn multi ->
    token = user_session.token |> Base.decode64!()

    Multi.insert(multi, :user_tokens, %UserTokenProjection{
      context: user_session.context,
      sent_to: user_session.sent_to,
      token: token,
      user_id: user_session.user_id,
      user_uuid: user_session.user_uuid,
      uuid: user_session.uuid
    })
  end)

  project(%UserTokensCleared{} = cleared, _metadata, fn multi ->
    queryable = UserTokenByUUID.new(cleared.uuid)

    Multi.delete_all(multi, :user_tokens, queryable)
  end)
end
