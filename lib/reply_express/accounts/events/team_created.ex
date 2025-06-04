defmodule ReplyExpress.Accounts.Events.TeamCreated do
  @moduledoc """
  Event emitted when a team is created.
  """

  @derive Jason.Encoder
  defstruct [:name, :uuid]
end
