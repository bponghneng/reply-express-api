defmodule ReplyExpress.Accounts.Projectors.User do
  @moduledoc """
  Projector extracting user state from domain events
  """

  use Commanded.Projections.Ecto,
    application: ReplyExpress.Commanded,
    consistency: :strong,
    name: "user",
    repo: ReplyExpress.Repo

  alias Ecto.Multi
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  project(%UserRegistered{} = user_registered, _metadata, fn multi ->
    Multi.insert(multi, :users, %UserProjection{
      email: user_registered.email,
      hashed_password: user_registered.hashed_password,
      uuid: user_registered.uuid
    })
  end)
end
