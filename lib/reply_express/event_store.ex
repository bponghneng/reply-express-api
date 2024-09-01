defmodule ReplyExpress.EventStore do
  @moduledoc """
  Configures PostgresSQL event store via `:commanded_eventstore_adapter`
  """

  use EventStore, otp_app: :reply_express
end
