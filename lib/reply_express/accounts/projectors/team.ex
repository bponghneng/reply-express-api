defmodule ReplyExpress.Accounts.Projectors.Team do
  @moduledoc """
  Projector for team-related events.
  """

  use Commanded.Projections.Ecto,
    application: ReplyExpress.Commanded,
    consistency: :strong,
    name: "teams",
    repo: ReplyExpress.Repo

  alias Ecto.Multi
  alias ReplyExpress.Accounts.Events.TeamCreated
  alias ReplyExpress.Accounts.Events.TeamRegistered
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection

  project(%TeamCreated{} = event, fn multi ->
    Multi.insert(multi, :teams, %TeamProjection{
      uuid: event.uuid,
      name: event.name
    })
  end)

  project(%TeamRegistered{} = event, fn multi ->
    Multi.insert(multi, :teams, %TeamProjection{
      uuid: event.uuid,
      name: event.name
    })
  end)

  @doc """
  Telemetry callback for test synchronization.
  """
  def after_update(event, metadata, changes) do
    :telemetry.execute(
      [:projector, :team],
      %{system_time: System.system_time()},
      %{event: event, metadata: metadata, changes: changes, projector: __MODULE__}
    )
  end
end
