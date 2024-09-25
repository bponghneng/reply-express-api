defmodule ReplyExpress.Accounts.Events.UserTokensCleared do
  @moduledoc """
  Domain event for the clearing of all of a user's user tokens
  """

  @derive Jason.Encoder

  defstruct uuid: ""
end
