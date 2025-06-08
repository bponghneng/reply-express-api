defmodule ReplyExpress.Accounts.Events.PasswordResetTokenGenerated do
  @moduledoc """
  Domain event for a login from an existing user
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          email: String.t(),
          token: String.t(),
          user_id: integer,
          user_uuid: String.t(),
          uuid: String.t()
        }

  defstruct email: "",
            token: nil,
            user_id: "",
            user_uuid: "",
            uuid: ""
end
