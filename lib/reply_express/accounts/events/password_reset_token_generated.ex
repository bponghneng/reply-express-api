defmodule ReplyExpress.Accounts.Events.PasswordResetTokenGenerated do
  @moduledoc """
  Domain event for a login from an existing user
  """

  @derive Jason.Encoder

  defstruct email: "",
            token: nil,
            user_id: "",
            user_uuid: "",
            uuid: ""
end
