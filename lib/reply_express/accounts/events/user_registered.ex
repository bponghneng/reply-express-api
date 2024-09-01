defmodule ReplyExpress.Accounts.Events.UserRegistered do
  @moduledoc """
  Domain event for a new user registration
  """

  @derive Jason.Encoder

  defstruct [
    :uuid,
    :email,
    :hashed_password
  ]
end
