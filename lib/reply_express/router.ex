defmodule ReplyExpress.Router do
  @moduledoc """
  Command router for the Commanded application
  """

  use Commanded.Commands.Router

  alias ReplyExpress.Accounts.Aggregates.Team
  alias ReplyExpress.Accounts.Aggregates.User
  alias ReplyExpress.Accounts.Aggregates.UserToken
  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Support.Middleware.Validate

  middleware(Validate)

  dispatch([CreateTeam], to: Team, identity: :uuid)
  dispatch([ClearUserTokens, LogInUser, RegisterUser, ResetPassword], to: User, identity: :uuid)
  dispatch([GeneratePasswordResetToken, StartUserSession], to: UserToken, identity: :uuid)
end
