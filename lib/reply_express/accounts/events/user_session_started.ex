defmodule ReplyExpress.Accounts.Events.UserSessionStarted do
  @moduledoc """
  Domain event for a user session started for an authenticated user
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          context: String.t(),
          sent_to: String.t(),
          token: String.t(),
          user_id: integer,
          user_uuid: String.t(),
          uuid: String.t()
        }

  defstruct [:context, :sent_to, :token, :user_id, :user_uuid, :uuid]
end
