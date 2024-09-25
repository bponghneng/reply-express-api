defmodule ReplyExpress.Accounts.Commands.ClearUserTokens do
  @moduledoc """
  Command to clear all of a user's user tokens
  """

  defstruct uuid: ""

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Validators.ValidUserUUID

  validates(:uuid, presence: [message: "can't be empty"], by: &ValidUserUUID.validate/2)
end
