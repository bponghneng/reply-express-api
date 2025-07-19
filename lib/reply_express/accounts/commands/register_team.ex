defmodule ReplyExpress.Accounts.Commands.RegisterTeam do
  @moduledoc """
  Command for registering a team during user registration workflow.
  """

  use ExConstructor
  use Vex.Struct

  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          user_registration_uuid: String.t()
        }

  defstruct [:uuid, :name, :user_registration_uuid]

  validates(:uuid, presence: [message: "can't be empty"])
  validates(:name, presence: [message: "can't be empty"])
  validates(:user_registration_uuid, presence: [message: "can't be empty"])
end
