defmodule ReplyExpress.Accounts.TeamsContext.Test do
  @moduledoc false

  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.TeamsContext
  alias ReplyExpress.Commanded

  @valid_team_attrs %{"name" => "Test Team"}
  @valid_user_attrs %{email: "test@example.com", password: "password1234"}

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

  describe "add_user_to_team/1" do
    setup do
      # Create user via command dispatch
      user_uuid = UUID.uuid4()

      create_user_command = %CreateUser{
        email: @valid_user_attrs.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_user_attrs.password),
        uuid: user_uuid
      }

      :ok = Commanded.dispatch(create_user_command, consistency: :strong)

      # Create team via command dispatch
      team_uuid = UUID.uuid4()

      create_team_command = %CreateTeam{
        uuid: team_uuid,
        name: @valid_team_attrs["name"]
      }

      :ok = Commanded.dispatch(create_team_command, consistency: :strong)

      # Get the projections created by the commands
      user_projection = Repo.get_by!(UserProjection, uuid: user_uuid)
      team_projection = Repo.get_by!(TeamProjection, uuid: team_uuid)

      %{
        user_uuid: user_uuid,
        team_uuid: team_uuid,
        user_projection: user_projection,
        team_projection: team_projection
      }
    end

    test "adds a user to a team successfully", %{
      team_uuid: team_uuid,
      user_uuid: user_uuid,
      team_projection: team_projection
    } do
      :telemetry.attach(
        "test-handler-team-user",
        [:projector, :team_user],
        fn event, measurements, metadata, reply_to ->
          send(reply_to, {:telemetry, event, measurements, metadata})
        end,
        self()
      )

      attrs = %{
        "team_uuid" => team_uuid,
        "user_uuid" => user_uuid,
        "role" => "member"
      }

      {:ok, team} = TeamsContext.add_user_to_team(attrs)

      # Wait for team user projection to complete
      assert_receive {:telemetry, [:projector, :team_user], _measurements,
                      %{event: %ReplyExpress.Accounts.Events.UserAddedToTeam{team_uuid: ^team_uuid, user_uuid: ^user_uuid}}}

      assert %TeamProjection{} = team
      assert team.uuid == team_projection.uuid
      assert team.name == team_projection.name

      # Assert that the team has the added user
      assert Enum.any?(team.team_users, fn team_user ->
               team_user.user.uuid == user_uuid
             end)

      :telemetry.detach("test-handler-team-user")
    end

    test "adds a user with admin role", %{
      team_uuid: team_uuid,
      user_uuid: user_uuid,
      team_projection: team_projection
    } do
      :telemetry.attach(
        "test-handler-team-user",
        [:projector, :team_user],
        fn event, measurements, metadata, reply_to ->
          send(reply_to, {:telemetry, event, measurements, metadata})
        end,
        self()
      )

      attrs = %{
        "team_uuid" => team_uuid,
        "user_uuid" => user_uuid,
        "role" => "admin"
      }

      {:ok, team} = TeamsContext.add_user_to_team(attrs)

      # Wait for team user projection to complete
      assert_receive {:telemetry, [:projector, :team_user], _measurements,
                      %{event: %ReplyExpress.Accounts.Events.UserAddedToTeam{team_uuid: ^team_uuid, user_uuid: ^user_uuid}}}

      assert %TeamProjection{} = team
      assert team.uuid == team_projection.uuid

      # Assert that the team has the added user
      assert Enum.any?(team.team_users, fn team_user -> team_user.user.uuid == user_uuid end)

      :telemetry.detach("test-handler-team-user")
    end

    test "validation failure for missing team_uuid", %{user_uuid: user_uuid} do
      attrs = %{
        "user_uuid" => user_uuid,
        "role" => "member"
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.team_uuid == ["can't be empty", "is invalid"]
    end

    test "validation failure for missing user_uuid", %{team_uuid: team_uuid} do
      attrs = %{
        "team_uuid" => team_uuid,
        "role" => "member"
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.user_uuid == ["can't be empty", "is invalid"]
    end

    test "validation failure for missing role", %{
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      attrs = %{
        "team_uuid" => team_uuid,
        "user_uuid" => user_uuid
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.role == ["can't be empty", "must be either \"admin,\" \"member\" or \"owner\""]
    end

    test "validation failure for invalid role", %{
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      attrs = %{
        "team_uuid" => team_uuid,
        "user_uuid" => user_uuid,
        "role" => "invalid_role"
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.role == ["must be either \"admin,\" \"member\" or \"owner\""]
    end

    test "validation failure for empty team_uuid", %{user_uuid: user_uuid} do
      attrs = %{
        "team_uuid" => "",
        "user_uuid" => user_uuid,
        "role" => "member"
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.team_uuid == ["can't be empty", "is invalid"]
    end

    test "validation failure for empty user_uuid", %{team_uuid: team_uuid} do
      attrs = %{
        "team_uuid" => team_uuid,
        "user_uuid" => "",
        "role" => "member"
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.user_uuid == ["can't be empty", "is invalid"]
    end

    test "validation failure for empty role", %{
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      attrs = %{
        "team_uuid" => team_uuid,
        "user_uuid" => user_uuid,
        "role" => ""
      }

      {:error, :validation_failure, errors} = TeamsContext.add_user_to_team(attrs)

      assert errors.role == ["can't be empty", "must be either \"admin,\" \"member\" or \"owner\""]
    end
  end
end
