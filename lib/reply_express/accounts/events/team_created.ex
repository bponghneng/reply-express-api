defmodule ReplyExpress.Accounts.Events.TeamCreated do
  @moduledoc """
  Event emitted when a team is created.
  """

  @derive Jason.Encoder

  @type t() :: %__MODULE__{
    name: String.t(),
    uuid: String.t()
  }

  defstruct [:name, :uuid]
end
