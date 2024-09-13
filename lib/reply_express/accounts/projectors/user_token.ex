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
  alias ReplyExpress.Accounts.Events.UserSessionTokenCreated
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  project(%UserSessionTokenCreated{} = created_user_token, _metadata, fn multi ->
    token = created_user_token.token |> Base.decode64!()

    Multi.insert(multi, :users, %UserTokenProjection{
      context: created_user_token.context,
      token: token,
      user_uuid: created_user_token.user_uuid,
      uuid: created_user_token.uuid
    })
  end)
end
