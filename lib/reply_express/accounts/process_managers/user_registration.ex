defmodule ReplyExpress.Accounts.ProcessManagers.UserRegistration do
  @moduledoc """
  Process manager that orchestrates team creation and user association upon user registration.

  This process manager handles the flow:
  1. User registers -> Creates a personal team
  2. Team is created -> Adds user to team as admin
  3. User is added to team -> Process completes
  """

  use Commanded.ProcessManagers.ProcessManager,
    application: ReplyExpress.Commanded,
    name: "UserRegistration"

  alias ReplyExpress.Accounts.Commands.RegisterTeam
  alias ReplyExpress.Accounts.Commands.RegisterUserToTeam
  alias ReplyExpress.Accounts.Events.TeamRegistered
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Events.UserRegisteredToTeam

  @derive Jason.Encoder
  @type t :: %__MODULE__{
          user_uuid: String.t() | nil,
          email: String.t() | nil,
          team_uuid: String.t() | nil,
          status: atom() | nil
        }

  defstruct [:user_uuid, :email, :team_uuid, :status]

  @doc """
  Determines if the process manager is interested in an event.

  - UserRegistered: Starts the process
  - TeamRegistered: Continues the process if user_registration_uuid matches
  - UserRegisteredToTeam: Stops the process if user_uuid matches
  """
  @spec interested?(any()) ::
          {:start, String.t()} | {:continue, String.t()} | {:stop, String.t()} | false
  def interested?(%UserRegistered{uuid: user_uuid}), do: {:start, user_uuid}

  def interested?(%TeamRegistered{user_registration_uuid: user_uuid}) when not is_nil(user_uuid),
    do: {:continue, user_uuid}

  def interested?(%UserRegisteredToTeam{user_uuid: user_uuid}), do: {:stop, user_uuid}

  def interested?(_event), do: false

  @doc """
  Handles events and dispatches appropriate commands.

  - UserRegistered: Dispatches RegisterTeam command
  - TeamRegistered: Dispatches RegisterUserToTeam command
  """
  @spec handle(t(), UserRegistered.t()) :: RegisterTeam.t()
  @spec handle(t(), TeamRegistered.t()) :: RegisterUserToTeam.t()
  def handle(%__MODULE__{}, %UserRegistered{uuid: user_uuid, email: email}) do
    team_name = derive_team_name(email)

    %RegisterTeam{
      uuid: UUID.uuid4(),
      name: team_name,
      user_registration_uuid: user_uuid
    }
  end

  def handle(%__MODULE__{user_uuid: user_uuid}, %TeamRegistered{uuid: team_uuid}) do
    %RegisterUserToTeam{
      team_uuid: team_uuid,
      user_uuid: user_uuid
    }
  end

  @doc """
  Applies events to update the process manager state.

  - UserRegistered: Sets user_uuid, email, and status
  - TeamRegistered: Sets team_uuid and updates status
  """
  @spec apply(t(), UserRegistered.t()) :: t()
  @spec apply(t(), TeamRegistered.t()) :: t()
  def apply(%__MODULE__{} = state, %UserRegistered{uuid: user_uuid, email: email}) do
    %__MODULE__{
      state
      | user_uuid: user_uuid,
        email: email,
        status: :team_registration_requested
    }
  end

  def apply(%__MODULE__{} = state, %TeamRegistered{uuid: team_uuid}) do
    %__MODULE__{
      state
      | team_uuid: team_uuid,
        status: :user_registration_requested
    }
  end

  # Derives a team name from the user's email address.
  # Examples:
  # - "test@example.com" -> "Test's Team"
  # - "john.doe@company.com" -> "John's Team"
  @spec derive_team_name(String.t()) :: String.t()
  defp derive_team_name(email) do
    email
    |> String.split("@")
    |> List.first()
    |> String.split(".")
    |> List.first()
    |> String.capitalize()
    |> Kernel.<>("'s Team")
  end
end
