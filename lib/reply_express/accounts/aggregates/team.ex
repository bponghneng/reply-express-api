defmodule ReplyExpress.Accounts.Aggregates.Team do
  @moduledoc """
  Team aggregate that handles team-related commands and emits events.
  """

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Events.TeamCreated

  @type t :: %__MODULE__{
          uuid: String.t() | nil,
          name: String.t() | nil
        }

  defstruct [:uuid, :name]

  @doc """
  Executes the CreateTeam command and returns a TeamCreated event.
  """
  @spec execute(t(), CreateTeam.t()) :: TeamCreated.t()

  def execute(%__MODULE__{uuid: nil}, %CreateTeam{} = command) do
    %TeamCreated{
      uuid: command.uuid,
      name: command.name
    }
  end

  @doc """
  Applies the TeamCreated event to the Team aggregate.
  """
  @spec apply(t(), TeamCreated.t()) :: t()

  def apply(%__MODULE__{} = team, %TeamCreated{} = event) do
    %__MODULE__{
      team
      | uuid: event.uuid,
        name: event.name
    }
  end
end
