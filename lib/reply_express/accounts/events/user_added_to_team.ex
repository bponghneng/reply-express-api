defmodule ReplyExpress.Accounts.Events.UserAddedToTeam do
  @moduledoc """
  Event emitted when a user is added to a team.
  """

  @derive Jason.Encoder

  @type t() :: %__MODULE__{
    team_uuid: String.t(),
    user_uuid: String.t(),
    role: String.t()
  }

  defstruct [:team_uuid, :user_uuid, :role]
end