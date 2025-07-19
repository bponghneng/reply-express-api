defmodule ReplyExpress.Accounts.Aggregates.Team do
  @moduledoc """
  Team aggregate that handles team-related commands and emits events.
  """

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.AddUserToTeam
  alias ReplyExpress.Accounts.Commands.RegisterTeam
  alias ReplyExpress.Accounts.Commands.RegisterUserToTeam
  alias ReplyExpress.Accounts.Events.TeamCreated
  alias ReplyExpress.Accounts.Events.UserAddedToTeam
  alias ReplyExpress.Accounts.Events.TeamRegistered
  alias ReplyExpress.Accounts.Events.UserRegisteredToTeam

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
  - RegisterTeam: Registers a new team during user registration and returns a TeamRegistered event,
    or returns an error if the team already exists
  - RegisterUserToTeam: Registers a user to an existing team during user registration and returns a UserRegisteredToTeam event,
    or returns an error if the team doesn't exist or user is already a member
  """
  @spec execute(t(), CreateTeam.t()) :: TeamCreated.t() | {:error, atom()}
  @spec execute(t(), AddUserToTeam.t()) :: UserAddedToTeam.t() | {:error, atom()}
  @spec execute(t(), RegisterTeam.t()) :: TeamRegistered.t() | {:error, atom()}
  @spec execute(t(), RegisterUserToTeam.t()) :: UserRegisteredToTeam.t() | {:error, atom()}

  def execute(%__MODULE__{} = team_aggregate, %CreateTeam{} = command) do
    case validate_team_exists(team_aggregate) do
      :ok ->
        {:error, :team_already_exists}

      {:error, _} ->
        %TeamCreated{
          uuid: command.uuid,
          name: command.name,
          user_registration_uuid: command.user_registration_uuid
        }
    end
  end

  def execute(%__MODULE__{uuid: uuid}, %CreateTeam{}) when not is_nil(uuid),
    do: {:error, :team_already_exists}

  def execute(%__MODULE__{uuid: nil}, %AddUserToTeam{}), do: {:error, :team_not_found}

  def execute(%__MODULE__{} = team, %AddUserToTeam{user_uuid: user_uuid} = command) do
    with :ok <- validate_not_member(team, user_uuid) do
      %UserAddedToTeam{
        team_uuid: command.team_uuid,
        user_uuid: command.user_uuid,
        role: command.role
      }
    end
  end

  def execute(%__MODULE__{} = team_aggregate, %RegisterTeam{} = command) do
    case validate_team_exists(team_aggregate) do
      :ok ->
        {:error, :team_already_exists}

      {:error, _} ->
        %TeamRegistered{
          uuid: command.uuid,
          name: command.name,
          user_registration_uuid: command.user_registration_uuid
        }
    end
  end

  def execute(%__MODULE__{uuid: nil}, %RegisterUserToTeam{}), do: {:error, :team_not_found}

  def execute(%__MODULE__{} = team, %RegisterUserToTeam{user_uuid: user_uuid} = command) do
    with :ok <- validate_not_member(team, user_uuid) do
      %UserRegisteredToTeam{
        team_uuid: command.team_uuid,
        user_uuid: command.user_uuid,
        role: command.role
      }
    end
  end

  defp validate_not_member(%__MODULE__{members: members}, user_uuid) do
    if MapSet.member?(members, user_uuid) do
      {:error, :user_already_member}
    else
      :ok
    end
  end

  defp validate_team_exists(%__MODULE__{uuid: nil}), do: {:error, :team_not_found}
  defp validate_team_exists(%__MODULE__{uuid: uuid}) when not is_nil(uuid), do: :ok

  @doc """
  Applies events to the Team aggregate.

  - TeamCreated: Initializes team state with uuid, name, and empty members set
  - UserAddedToTeam: Adds user to the members set
  - TeamRegistered: Initializes team state with uuid, name, and empty members set
  - UserRegisteredToTeam: Adds user to the members set
  """
  @spec apply(t(), TeamCreated.t()) :: t()
  @spec apply(t(), UserAddedToTeam.t()) :: t()
  @spec apply(t(), TeamRegistered.t()) :: t()
  @spec apply(t(), UserRegisteredToTeam.t()) :: t()

  def apply(%__MODULE__{} = team, event) when event.__struct__ in [TeamCreated, TeamRegistered] do
    %__MODULE__{
      team
      | uuid: event.uuid,
        name: event.name,
        members: MapSet.new()
    }
  end

  def apply(%__MODULE__{members: members} = team, event)
      when event.__struct__ in [UserAddedToTeam, UserRegisteredToTeam] do
    %__MODULE__{
      team
      | members: MapSet.put(members, event.user_uuid)
    }
  end
end
