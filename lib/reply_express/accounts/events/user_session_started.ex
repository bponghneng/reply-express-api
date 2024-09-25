defmodule ReplyExpress.Accounts.Events.UserSessionStarted do
  @moduledoc """
  Domain event for a user session started for an authenticated user
  """

  @derive Jason.Encoder

  defstruct [:context, :sent_to, :token, :user_id, :user_uuid, :uuid]
end
