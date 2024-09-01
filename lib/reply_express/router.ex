defmodule ReplyExpress.Router do
  @moduledoc """
  Command router for the Commanded application
  """

  use Commanded.Commands.Router

  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Commands.RegisterUser

  dispatch(RegisterUser, to: User, identity: :uuid)
end
