defmodule ReplyExpress.Accounts.Supervisor do
  @moduledoc false

  use Supervisor

  alias ReplyExpress.Accounts.ProcessManagers.UserRegistration
  alias ReplyExpress.Accounts.Projectors.Team, as: TeamProjector
  alias ReplyExpress.Accounts.Projectors.TeamUser, as: TeamUserProjector
  alias ReplyExpress.Accounts.Projectors.User, as: UserProjector
  alias ReplyExpress.Accounts.Projectors.UserToken, as: UserTokenProjector

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        TeamProjector,
        TeamUserProjector,
        UserProjector,
        UserTokenProjector,
        UserRegistration
      ],
      strategy: :one_for_one
    )
  end
end
