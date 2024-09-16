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
  alias ReplyExpress.Accounts.Events.UserSessionStarted
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  project(%UserSessionStarted{} = user_session, _metadata, fn multi ->
    token = user_session.token |> Base.decode64!()

    Multi.insert(multi, :users, %UserTokenProjection{
      context: user_session.context,
      token: token,
      user_uuid: user_session.user_uuid,
      uuid: user_session.uuid
    })
  end)
end
