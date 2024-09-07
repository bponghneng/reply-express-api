defmodule ReplyExpress.Storage do
  @doc """
  Reset the event store and read store databases.
  """
  def reset! do
    :ok = Application.stop(:reply_express)

    reset_eventstore!()
    reset_readstore!()

    {:ok, _} = Application.ensure_all_started(:reply_express)
  end

  defp reset_eventstore! do
    {:ok, conn} =
      ReplyExpress.EventStore.config()
      |> EventStore.Config.default_postgrex_opts()
      |> Postgrex.start_link()

    EventStore.Storage.Initializer.reset!(conn, ReplyExpress.EventStore.config())
  end

  defp reset_readstore! do
    {:ok, conn} = Postgrex.start_link(ReplyExpress.Repo.config())

    Postgrex.query!(conn, truncate_readstore_tables(), [])
  end

  defp truncate_readstore_tables do
    """
    TRUNCATE TABLE
      projection_versions,
      users,
      user_tokens
    RESTART IDENTITY
    CASCADE;
    """
  end
end
