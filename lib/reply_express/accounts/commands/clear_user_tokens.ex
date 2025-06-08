defmodule ReplyExpress.Accounts.Commands.ClearUserTokens do
  @moduledoc """
  Command to clear all tokens for a user.
  """

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Validators.ValidUserUUID

  @type t :: %__MODULE__{
    uuid: String.t()
  }

  defstruct uuid: ""

  validates(:uuid, presence: [message: "can't be empty"], by: &ValidUserUUID.validate/2)
end
