defmodule ReplyExpress.Accounts.UserTokensContext do
  @moduledoc """
  The UserTokens context.
  """

  import Ecto.Query, warn: false

  alias ReplyExpress.Accounts.Queries.UserTokenByToken
  alias ReplyExpress.Accounts.Queries.UserTokenByUUID
  alias ReplyExpress.Repo

  def user_session_token_by_user_uuid(uuid) do
    uuid
    |> UserTokenByUUID.new()
    |> where([ut], ut.context == "session")
    |> Repo.one()
  end

  def user_reset_password_token_by_user_uuid(uuid) do
    uuid
    |> UserTokenByUUID.new()
    |> where([ut], ut.context == "reset_password")
    |> preload(:user)
    |> Repo.one()
  end

  def user_reset_password_token_by_token(token) do
    token
    |> UserTokenByToken.new()
    |> where([ut], ut.context == "reset_password")
    |> preload(:user)
    |> Repo.one()
  end
end
