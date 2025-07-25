# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :reply_express,
  ecto_repos: [ReplyExpress.Repo],
  event_stores: [ReplyExpress.EventStore],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :reply_express, ReplyExpressWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: ReplyExpressWeb.API.V1.ErrorJSON],
    layout: false
  ],
  pubsub_server: ReplyExpress.PubSub,
  live_view: [signing_salt: "j6xTheEQ"]

# Configures CQRS
config :reply_express, ReplyExpress.Commanded,
  pub_sub: :local,
  registry: :local

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :reply_express, ReplyExpress.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :reply_express, env: config_env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
