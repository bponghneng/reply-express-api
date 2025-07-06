defmodule ReplyExpress.Accounts.Aggregates.Team do
  @moduledoc """
  Team aggregate that handles team-related commands and emits events.
  """

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.AddUserToTeam
  alias ReplyExpress.Accounts.Events.TeamCreated
  alias ReplyExpress.Accounts.Events.UserAddedToTeam

  @type t :: %__MODULE__{
          uuid: String.t() | nil,
          name: String.t() | nil,
          members: MapSet.t(String.t())
        }

  defstruct [:uuid, :name, members: MapSet.new()]

  @doc """
  Executes commands for the Team aggregate.
  
  - CreateTeam: Creates a new team and returns a TeamCreated event,
    or returns an error if the team already exists
  - AddUserToTeam: Adds a user to an existing team and returns a UserAddedToTeam event,
    or returns an error if the team doesn't exist or user is already a member
  """
  @spec execute(t(), CreateTeam.t()) :: TeamCreated.t() | {:error, atom()}
  @spec execute(t(), AddUserToTeam.t()) :: UserAddedToTeam.t() | {:error, atom()}

  def execute(%__MODULE__{uuid: nil}, %CreateTeam{} = command) do
    %TeamCreated{
      uuid: command.uuid,
      name: command.name,
      user_registration_uuid: command.user_registration_uuid
    }
  end

  def execute(%__MODULE__{uuid: uuid}, %CreateTeam{}) when not is_nil(uuid), do: {:error, :team_already_exists}

  def execute(%__MODULE__{uuid: nil}, %AddUserToTeam{}), do: {:error, :team_not_found}

  def execute(%__MODULE__{members: members} = _team, %AddUserToTeam{user_uuid: user_uuid} = command) do
    if MapSet.member?(members, user_uuid) do
      {:error, :user_already_member}
    else
      %UserAddedToTeam{
        team_uuid: command.team_uuid,
        user_uuid: command.user_uuid,
        role: command.role
      }
    end
  end

  @doc """
  Applies events to the Team aggregate.
  
  - TeamCreated: Initializes team state with uuid, name, and empty members set
  - UserAddedToTeam: Adds user to the members set
  """
  @spec apply(t(), TeamCreated.t()) :: t()
  @spec apply(t(), UserAddedToTeam.t()) :: t()

  def apply(%__MODULE__{} = team, %TeamCreated{} = event) do
    %__MODULE__{
      team
      | uuid: event.uuid,
        name: event.name,
        members: MapSet.new()
    }
  end

  def apply(%__MODULE__{members: members} = team, %UserAddedToTeam{user_uuid: user_uuid}) do
    %__MODULE__{
      team
      | members: MapSet.put(members, user_uuid)
    }
  end
end
