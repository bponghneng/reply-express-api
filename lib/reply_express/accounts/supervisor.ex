defmodule ReplyExpress.Accounts.Supervisor do
  use Supervisor

  alias ReplyExpress.Accounts.Projectors.User, as: UserProjector

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init([UserProjector], strategy: :one_for_one)
  end
end
