defmodule ReplyExpress.Accounts.Events.UserTokensCleared do
  @moduledoc """
  Domain event for the clearing of all of a user's user tokens
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          uuid: String.t()
        }

  defstruct uuid: ""
end
