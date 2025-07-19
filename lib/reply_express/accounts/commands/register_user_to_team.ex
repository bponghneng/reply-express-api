defmodule ReplyExpress.Accounts.Commands.RegisterUserToTeam do
  @moduledoc """
  Command for registering a user to a team during user registration workflow.
  The user is always registered as an admin for their personal team.
  """

  use ExConstructor
  use Vex.Struct

  @type t :: %__MODULE__{
          team_uuid: String.t(),
          user_uuid: String.t(),
          role: String.t()
        }

  defstruct [:team_uuid, :user_uuid, role: "admin"]

  validates(:team_uuid, presence: [message: "can't be empty"])
  validates(:user_uuid, presence: [message: "can't be empty"])
end
