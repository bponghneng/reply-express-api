defmodule ReplyExpress.Router do
  @moduledoc """
  Command router for the Commanded application
  """

  use Commanded.Commands.Router

  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Support.Middleware.Validate

  middleware(Validate)

  dispatch([StartUserSession, LogInUser, RegisterUser], to: User, identity: :uuid)
end
