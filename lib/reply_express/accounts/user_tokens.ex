defmodule ReplyExpress.Accounts.UserTokens do
  @moduledoc """
    Service module to look up users by way of bearer tokens
  """
  alias ReplyExpress.Accounts.UserToken
  alias ReplyExpress.Repo

  def get_session_tokens_by_user(user) do
    user
    |> UserToken.by_user_and_contexts_query(["session"])
    |> Repo.all()
  end
end
