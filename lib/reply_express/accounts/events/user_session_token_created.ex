defmodule ReplyExpress.Accounts.Events.UserSessionTokenCreated do
  @moduledoc """
  Domain event for a user session created from an authenticated user
  """

  @derive Jason.Encoder

  defstruct [:token, :user_uuid]
end
