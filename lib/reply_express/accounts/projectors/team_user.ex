defmodule ReplyExpress.Accounts.Projectors.TeamUser do
  @moduledoc """
  Projector for team user related events.
  """

  use Commanded.Projections.Ecto,
    application: ReplyExpress.Commanded,
    consistency: :strong,
    name: "team_users",
    repo: ReplyExpress.Repo

  alias Ecto.Multi
  alias ReplyExpress.Accounts.Events.UserAddedToTeam
  alias ReplyExpress.Accounts.Events.UserRegisteredToTeam
  alias ReplyExpress.Accounts.Projections.TeamUser, as: TeamUserProjection

  project(%UserAddedToTeam{} = event, fn multi ->
    attrs =
      event
      |> Map.from_struct()
      |> Map.take([:team_uuid, :user_uuid, :role])

    %TeamUserProjection{}
    |> TeamUserProjection.changeset(attrs)
    |> then(fn changeset ->
      if changeset.valid?,
        do: Multi.insert(multi, :team_users, changeset),
        else: {:error, changeset}
    end)
  end)

  project(%UserRegisteredToTeam{} = event, fn multi ->
    attrs =
      event
      |> Map.from_struct()
      |> Map.take([:team_uuid, :user_uuid, :role])

    %TeamUserProjection{}
    |> TeamUserProjection.changeset(attrs)
    |> then(fn changeset ->
      if changeset.valid?,
        do: Multi.insert(multi, :team_users, changeset),
        else: {:error, changeset}
    end)
  end)

  @doc """
  Telemetry callback for test synchronization.
  """
  def after_update(event, metadata, changes) do
    :telemetry.execute(
      [:projector, :team_user],
      %{system_time: System.system_time()},
      %{event: event, metadata: metadata, changes: changes, projector: __MODULE__}
    )
  end
end
