defmodule ReplyExpress.Accounts.Events.PasswordReset do
  @moduledoc """
  Domain event for reset of a user password
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
    hashed_password: String.t(),
    uuid: String.t()
  }

  defstruct [:hashed_password, :uuid]
end
