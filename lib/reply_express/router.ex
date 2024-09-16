defmodule ReplyExpress.Router do
  @moduledoc """
  Command router for the Commanded application
  """

  use Commanded.Commands.Router

  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Aggregates.UserToken
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.SendPasswordResetToken
  alias ReplyExpress.Support.Middleware.Validate

  middleware(Validate)

  dispatch([LogInUser, RegisterUser], to: User, identity: :uuid)
  dispatch([StartUserSession], to: UserToken, identity: :uuid)
end
