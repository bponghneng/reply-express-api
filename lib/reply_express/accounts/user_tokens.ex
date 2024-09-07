defmodule ReplyExpress.UserTokens do
  @moduledoc """
  The UserTokens context.
  """

  import Ecto.Query, warn: false

  alias ReplyExpress.Accounts.Queries.UserTokenByUUID
  alias ReplyExpress.Repo

  def user_token_by_user_uuid(uuid) do
    uuid
    |> UserTokenByUUID.new()
    |> Repo.one()
  end
end
