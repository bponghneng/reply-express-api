defmodule ReplyExpress.Commanded do
  @moduledoc """
  Commanded application
  """

  use Commanded.Application,
    otp_app: :reply_express,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: ReplyExpress.EventStore
    ]

  alias ReplyExpress.Router

  # Single router for entire application. May be split for cohesion at the application grows.
  router(Router)
end
