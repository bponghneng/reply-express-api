defmodule ReplyExpress.InMemoryEventStoreCase do
  @moduledoc """
  This module provides a test case template for tests that require an in-memory event store.
  It handles the setup and teardown of the ReplyExpress application for each test.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias ReplyExpress.Repo

      import Commanded.Assertions.EventAssertions
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
    end
  end

  setup do
    # Reset the event store and database before each test
    ReplyExpress.Storage.reset!()

    # Reset the in-memory event store
    :ok = Application.stop(:reply_express)
    {:ok, _apps} = Application.ensure_all_started(:reply_express)

    on_exit(fn ->
      :ok = Application.stop(:reply_express)
    end)

    :ok
  end
end
