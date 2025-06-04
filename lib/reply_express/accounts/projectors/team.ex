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
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection

  project(%TeamCreated{} = event, fn multi ->
    Multi.insert(multi, :teams, %TeamProjection{
      uuid: event.uuid,
      name: event.name
    })
  end)
end
