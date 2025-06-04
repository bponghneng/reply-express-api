defmodule ReplyExpress.Accounts.Aggregates.Team do
  @moduledoc """
  Team aggregate that handles team-related commands and emits events.
  """

  defstruct [:uuid, :name]

  alias ReplyExpress.Accounts.Aggregates.Team
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Events.TeamCreated

  @doc """
  Executes the CreateTeam command and returns a TeamCreated event.
  """
  def execute(%Team{uuid: nil}, %CreateTeam{} = command) do
    %TeamCreated{
      uuid: command.uuid,
      name: command.name
    }
  end

  @doc """
  Applies the TeamCreated event to the Team aggregate.
  """
  def apply(%Team{} = team, %TeamCreated{} = event) do
    %Team{
      team
      | uuid: event.uuid,
        name: event.name
    }
  end
end
