defmodule ReplyExpress.Accounts.Events.UserRegistered do
  @moduledoc """
  Domain event for a new user registration
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
    uuid: String.t(),
    email: String.t(),
    hashed_password: String.t()
  }

  defstruct [
    :uuid,
    :email,
    :hashed_password
  ]
end
