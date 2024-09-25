defmodule ReplyExpress.Accounts.Supervisor do
  use Supervisor

  alias ReplyExpress.Accounts.Projectors.User, as: UserProjector
  alias ReplyExpress.Accounts.Projectors.UserToken, as: UserTokenProjector

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([UserProjector, UserTokenProjector], strategy: :one_for_one)
  end
end
