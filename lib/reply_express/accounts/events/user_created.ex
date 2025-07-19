defmodule ReplyExpress.Accounts.Events.UserCreated do
  @moduledoc """
  Event emitted when a user is created (distinct from user registration).

  This event is emitted for user creation that does not trigger the
  automatic team creation process.
  """

  @derive Jason.Encoder

  @type t() :: %__MODULE__{
          uuid: String.t(),
          email: String.t(),
          hashed_password: String.t()
        }

  defstruct [:uuid, :email, :hashed_password]
end
