defmodule ReplyExpress.Storage do
  @moduledoc """
  Provides utilities for resetting the storage state during tests.
  """

  @doc """
  Reset the event store and read store databases.
  """
  def reset! do
    case Application.stop(:reply_express) do
      :ok -> :ok
      {:error, {:not_started, _}} -> :ok
    end

    reset_eventstore!()
    reset_readstore!()

    {:ok, _} = Application.ensure_all_started(:reply_express)
  end

  def reset_eventstore! do
    {:ok, conn} =
      ReplyExpress.EventStore.config()
      |> EventStore.Config.default_postgrex_opts()
      |> Postgrex.start_link()

    EventStore.Storage.Initializer.reset!(conn, ReplyExpress.EventStore.config())
  end

  def reset_readstore! do
    config = Application.get_env(:reply_express, ReplyExpress.Repo)

    {:ok, conn} = Postgrex.start_link(config)

    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
      projection_versions,
      teams,
      teams_users,
      user_tokens,
      users
    RESTART IDENTITY
    CASCADE;
    """
  end
end
