defmodule ReplyExpress.Accounts.Events.PasswordReset do
  @moduledoc """
  Domain event for reset of a user password
  """

  @derive Jason.Encoder

  defstruct [:hashed_password, :uuid]
end
