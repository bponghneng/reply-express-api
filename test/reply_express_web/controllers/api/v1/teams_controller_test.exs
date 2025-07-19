defmodule ReplyExpressWeb.API.V1.TeamsControllerTest do
  @moduledoc false

  use ReplyExpressWeb.ConnCase

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Commanded

  @valid_team_attrs %{name: "Test Team"}
  @valid_user_attrs %{email: "test@example.com", password: "password1234"}

  describe "create/2" do
    test "creates a team when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/teams", team: @valid_team_attrs)
      assert %{"uuid" => uuid, "name" => name} = json_response(conn, 201)["data"]
      assert name == @valid_team_attrs.name
      assert uuid != nil
    end

    test "returns error when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/teams", team: %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "add_user/2" do
    setup do
      # Attach telemetry handler for projection synchronization
      :telemetry.attach(
        "test-handler-user",
        [:projector, :user],
        fn event, measurements, metadata, reply_to ->
          send(reply_to, {:telemetry, event, measurements, metadata})
        end,
        self()
      )

      :telemetry.attach(
        "test-handler-team",
        [:projector, :team],
        fn event, measurements, metadata, reply_to ->
          send(reply_to, {:telemetry, event, measurements, metadata})
        end,
        self()
      )

      # Create user via command dispatch
      user_uuid = UUID.uuid4()

      create_user_command = %CreateUser{
        email: @valid_user_attrs.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_user_attrs.password),
        uuid: user_uuid
      }

      :ok = Commanded.dispatch(create_user_command, consistency: :strong)

      # Wait for user projection to complete
      assert_receive {:telemetry, [:projector, :user], _measurements,
                      %{event: %ReplyExpress.Accounts.Events.UserCreated{uuid: ^user_uuid}}}

      # Create team via command dispatch
      team_uuid = UUID.uuid4()

      create_team_command = %CreateTeam{
        uuid: team_uuid,
        name: @valid_team_attrs.name
      }

      :ok = Commanded.dispatch(create_team_command, consistency: :strong)

      # Wait for team projection to complete
      assert_receive {:telemetry, [:projector, :team], _measurements,
                      %{event: %ReplyExpress.Accounts.Events.TeamCreated{uuid: ^team_uuid}}}

      # Get the projections created by the commands
      user_projection = Repo.get_by!(UserProjection, uuid: user_uuid)
      team_projection = Repo.get_by!(TeamProjection, uuid: team_uuid)

      on_exit(fn ->
        :telemetry.detach("test-handler-user")
        :telemetry.detach("test-handler-team")
      end)

      %{
        user_uuid: user_uuid,
        team_uuid: team_uuid,
        user_projection: user_projection,
        team_projection: team_projection
      }
    end

    test "adds a user to a team when data is valid", %{
      conn: conn,
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => user_uuid,
          "role" => "member"
        })

      assert response(conn, 200)
    end

    test "adds a user as admin to a team", %{
      conn: conn,
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => user_uuid,
          "role" => "admin"
        })

      assert response(conn, 200)
    end

    test "returns error when user_uuid is missing", %{conn: conn, team_uuid: team_uuid} do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "role" => "member"
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when role is missing", %{
      conn: conn,
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => user_uuid
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when role is invalid", %{
      conn: conn,
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => user_uuid,
          "role" => "invalid_role"
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when team does not exist", %{conn: conn, user_uuid: user_uuid} do
      non_existent_team_uuid = UUID.uuid4()

      conn =
        post(conn, ~p"/api/v1/teams/#{non_existent_team_uuid}/add-user", %{
          "user_uuid" => user_uuid,
          "role" => "member"
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when user does not exist", %{conn: conn, team_uuid: team_uuid} do
      non_existent_user_uuid = UUID.uuid4()

      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => non_existent_user_uuid,
          "role" => "member"
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when request body is empty", %{conn: conn, team_uuid: team_uuid} do
      conn = post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{})

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when user_uuid is empty", %{conn: conn, team_uuid: team_uuid} do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => "",
          "role" => "member"
        })

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "returns error when role is empty", %{
      conn: conn,
      team_uuid: team_uuid,
      user_uuid: user_uuid
    } do
      conn =
        post(conn, ~p"/api/v1/teams/#{team_uuid}/add-user", %{
          "user_uuid" => user_uuid,
          "role" => ""
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
