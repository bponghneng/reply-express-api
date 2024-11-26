defmodule ReplyExpress.Accounts.Projections.Team do
  @moduledoc """
  Backing schema for team state projected from events
  """

  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime_usec]

  schema "teams" do
    field :name, :string
    field :uuid, :binary_id

    timestamps()
  end
end
