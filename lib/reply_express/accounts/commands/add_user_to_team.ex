defmodule ReplyExpress.Accounts.Commands.AddUserToTeam do
  @moduledoc """
  Command for adding a user to a team.
  """

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Validators.ValidUserUUID
  alias ReplyExpress.Accounts.Validators.ValidTeamUUID

  @type t :: %__MODULE__{
          team_uuid: String.t(),
          user_uuid: String.t(),
          role: String.t()
        }

  defstruct [:team_uuid, :user_uuid, :role]

  validates(:team_uuid,
    presence: [message: "can't be empty"],
    by: &ValidTeamUUID.validate/2
  )

  validates(:user_uuid,
    presence: [message: "can't be empty"],
    by: &ValidUserUUID.validate/2
  )

  validates(:role,
    presence: [message: "can't be empty"],
    inclusion: [
      in: ["admin", "member", "owner"],
      message: "must be either \"admin,\" \"member\" or \"owner\""
    ]
  )

  @doc """
  Sets the team UUID for the command.
  """
  def set_team_uuid(%__MODULE__{} = command, team_uuid) do
    %{command | team_uuid: team_uuid}
  end

  @doc """
  Sets the user UUID for the command.
  """
  def set_user_uuid(%__MODULE__{} = command, user_uuid) do
    %{command | user_uuid: user_uuid}
  end

  @doc """
  Sets the role for the user.
  """
  def set_role(%__MODULE__{} = command, role) do
    %{command | role: role}
  end
end
