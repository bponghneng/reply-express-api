defmodule ReplyExpress.Accounts.Validators.ValidTeamUUID do
  @moduledoc """
  Custom Vex.Validator to validate that a uuid represents an existing team
  """

  use Vex.Validator

  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.TeamsContext

  @doc """
  Returns an error tuple with message if a team does not exist
  """
  def validate(value, _context) when is_nil(value) or value == "" do
    {:error, "is invalid"}
  end

  def validate(value, _context) when is_binary(value) do
    value
    |> TeamsContext.team_by_uuid()
    |> case do
      %TeamProjection{} -> :ok
      _ -> {:error, "is invalid"}
    end
  end

  def validate(_value, _context) do
    {:error, "is invalid"}
  end
end
