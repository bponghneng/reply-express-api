import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :reply_express, ReplyExpress.Repo,
  username: "postgres",
  password: System.get_env("DATABASE_PASS", "postgres"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  database: "reply_express_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :reply_express, ReplyExpressWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "p3DoyOJDB4vMb7fnHTd9rDWorhZ0iqZfMppBpvwBpVHLAK1MkOMO2N1LOA6tvBXT",
  server: false

# In test we don't send emails
config :reply_express, ReplyExpress.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
