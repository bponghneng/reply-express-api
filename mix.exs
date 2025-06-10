defmodule ReplyExpress.MixProject do
  @moduledoc """
  Mix project configuration for the ReplyExpress application.
  Handles dependencies, compilation, and project settings.
  """
  use Mix.Project

  def project do
    [
      app: :reply_express,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ReplyExpress.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bandit, "~> 1.5"},
      {:commanded, "~> 1.4"},
      {:commanded_ecto_projections, "~> 1.4"},
      {:commanded_eventstore_adapter, "~> 1.4"},
      {:cors_plug, "~> 3.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_sql, "~> 3.10"},
      {:elixir_uuid, "~> 1.2"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_sqs, "~> 3.3"},
      {:exconstructor, "~> 1.2.11"},
      {:ex_machina, "~> 2.8.0"},
      {:finch, "~> 0.13"},
      {:gen_smtp, "~> 1.1"},
      {:gettext, "~> 0.20"},
      {:hackney, "~> 1.20"},
      {:jason, "~> 1.2"},
      {:pbkdf2_elixir, "~> 2.0"},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:postgrex, ">= 0.0.0"},
      {:swoosh, "~> 1.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:tesla, "~> 1.12"},
      {:timex, "~> 3.0"},
      {:vex, "~> 0.9"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "eventstore.reset": ["event_store.drop -e ReplyExpress.EventStore", "eventstore.setup"],
      "eventstore.setup": ["event_store.create", "event_store.init"],
      "reset.dev": ["eventstore.reset", "ecto.reset"],
      "eventstore.reset.test": [fn _ -> Mix.env(:test) end, "eventstore.reset"],
      "ecto.reset.test": [fn _ -> Mix.env(:test) end, "ecto.reset"],
      "reset.test": ["eventstore.reset.test", "ecto.reset.test"],
      setup: ["deps.get", "ecto.setup"],
      test: [
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "test"
      ]
    ]
  end
end
