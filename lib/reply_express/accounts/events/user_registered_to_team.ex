defmodule ReplyExpress.Accounts.Events.UserRegisteredToTeam do
  @moduledoc """
  Event emitted when a user is registered to a team during user registration workflow.
  The user is always registered as an admin for their personal team.
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          team_uuid: String.t(),
          user_uuid: String.t(),
          role: String.t()
        }

  defstruct [:team_uuid, :user_uuid, role: "admin"]
end
