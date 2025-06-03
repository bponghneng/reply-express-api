defmodule ReplyExpress.Accounts.TeamsContext.Test do
  @moduledoc false

  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.TeamsContext
  alias ReplyExpress.Commanded

  @valid_team_attrs %{"name" => "Test Team"}

  describe "create_team/1" do
    test "Creates new team from valid data" do
      {:ok, %TeamProjection{} = team} = TeamsContext.create_team(@valid_team_attrs)

      assert team.name == @valid_team_attrs["name"]
    end

    test "Validates name is present" do
      {:error, :validation_failure, errors} = TeamsContext.create_team(%{})

      assert errors == %{name: ["can't be empty"]}
    end
  end

  describe "team_by_uuid/1" do
    setup do
      command = %CreateTeam{
        name: @valid_team_attrs["name"],
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(command, consistency: :strong)

      %{command: command}
    end

    test "returns team when uuid exists", %{command: command} do
      assert %TeamProjection{} = team = TeamsContext.team_by_uuid(command.uuid)
      assert team.uuid == command.uuid
      assert team.name == command.name
    end

    test "returns nil when uuid does not exist" do
      assert is_nil(TeamsContext.team_by_uuid(UUID.uuid4()))
    end
  end
end
