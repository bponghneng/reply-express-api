defmodule ReplyExpress.Accounts.Events.UserLoggedIn do
  @moduledoc """
  Domain event for a login from an existing user
  """

  @derive Jason.Encoder

  defstruct [:credentials, :logged_in_at, :uuid]
end
