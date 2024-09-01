defmodule ReplyExpress.Storage do
  alias EventStore.Storage.Initializer
  alias ReplyExpress.EventStore

  @doc """
  Clear the event store and read store databases
  """
  def reset! do
    reset_eventstore()
    reset_readstore()
  end

  defp reset_eventstore do
    config = EventStore.config()

    {:ok, conn} = Postgrex.start_link(config)

    Initializer.reset!(conn, config)
  end

  defp reset_readstore do
    config = Application.get_env(:reply_express, ReplyExpress.Repo)

    {:ok, conn} = Postgrex.start_link(config)

    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
      users,
      projection_versions
    RESTART IDENTITY
    CASCADE;
    """
  end
end
