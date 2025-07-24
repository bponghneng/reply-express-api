defmodule ReplyExpress.Accounts.Events.UserLoggedIn do
  @moduledoc """
  Domain event for a login from an existing user
  """

  @derive Jason.Encoder

  @type t :: %__MODULE__{
          email: String.t(),
          logged_in_at: DateTime.t(),
          uuid: String.t()
        }

  defstruct [:email, :logged_in_at, :uuid]
end
