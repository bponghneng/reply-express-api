defmodule ReplyExpress.Accounts.Projectors.User do
  @moduledoc """
  Projector extracting user state from domain events
  """

  use Commanded.Projections.Ecto,
    application: ReplyExpress.Commanded,
    consistency: :strong,
    name: "users",
    repo: ReplyExpress.Repo

  alias Ecto.Multi
  alias ReplyExpress.Accounts.Events.PasswordReset
  alias ReplyExpress.Accounts.Events.UserLoggedIn
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  project(%PasswordReset{} = reset, _metadata, fn multi ->
    update_user(multi, reset.uuid, hashed_password: reset.hashed_password)
  end)

  project(%UserLoggedIn{} = user_logged_in, _metadata, fn multi ->
    logged_in_at =
      user_logged_in.logged_in_at
      |> Timex.parse!("{ISO:Extended:Z}")
      |> DateTime.truncate(:second)

    update_user(multi, user_logged_in.uuid, logged_in_at: logged_in_at)
  end)

  project(%UserRegistered{} = user_registered, _metadata, fn multi ->
    Multi.insert(multi, :users, %UserProjection{
      email: user_registered.email,
      hashed_password: user_registered.hashed_password,
      uuid: user_registered.uuid
    })
  end)

  defp update_user(multi, uuid, changes) do
    Ecto.Multi.update_all(multi, :user, user_query(uuid), set: changes)
  end

  defp user_query(uuid) do
    from(u in UserProjection, where: u.uuid == ^uuid)
  end
end
