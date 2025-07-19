defmodule ReplyExpress.Accounts.Events.TeamRegistered do
  @moduledoc """
  Event emitted when a team is registered during user registration workflow.
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          user_registration_uuid: String.t()
        }

  defstruct [:uuid, :name, :user_registration_uuid]
end
