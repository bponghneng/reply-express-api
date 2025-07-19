defmodule ReplyExpress.Accounts.Projectors.TeamUserProjectorTest do
  @moduledoc false

  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Events.UserAddedToTeam
  alias ReplyExpress.Accounts.Projections.TeamUser
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projectors.TeamUser, as: TeamUserProjector
  alias ReplyExpress.Commanded

  @valid_user_attrs %{email: "test@example.com", password: "password1234"}
  @valid_team_attrs %{name: "Test Team"}

  describe "UserAddedToTeam event projection" do
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
        name: @valid_team_attrs.name
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

    test "creates a TeamUser record when user is added to team", %{
      user_projection: user_projection,
      team_projection: team_projection
    } do
      # Create the event
      event = %UserAddedToTeam{
        team_uuid: team_projection.uuid,
        user_uuid: user_projection.uuid,
        role: "member"
      }

      # Project the event
      :ok = TeamUserProjector.handle(event, %{event_number: 1, handler_name: "team_users"})

      # Verify the projection was created
      team_user =
        TeamUser
        |> where(
          [tu],
          tu.team_uuid == ^team_projection.uuid and tu.user_uuid == ^user_projection.uuid
        )
        |> Repo.one()

      assert team_user != nil
      assert team_user.role == "member"
      assert team_user.team_uuid == team_projection.uuid
      assert team_user.user_uuid == user_projection.uuid
    end

    test "creates a TeamUser record with admin role", %{
      user_projection: user_projection,
      team_projection: team_projection
    } do
      # Create the event
      event = %UserAddedToTeam{
        team_uuid: team_projection.uuid,
        user_uuid: user_projection.uuid,
        role: "admin"
      }

      # Project the event
      :ok = TeamUserProjector.handle(event, %{event_number: 1, handler_name: "team_users"})

      # Verify the projection was created with admin role
      team_user =
        TeamUser
        |> where(
          [tu],
          tu.team_uuid == ^team_projection.uuid and tu.user_uuid == ^user_projection.uuid
        )
        |> Repo.one()

      assert team_user != nil
      assert team_user.role == "admin"
      assert team_user.team_uuid == team_projection.uuid
      assert team_user.user_uuid == user_projection.uuid
    end

    test "handles multiple users being added to the same team", %{
      team_projection: team_projection
    } do
      # Create second user via command dispatch
      user2_uuid = UUID.uuid4()

      create_user2_command = %CreateUser{
        email: "user2@example.com",
        hashed_password: Pbkdf2.hash_pwd_salt("password1234"),
        uuid: user2_uuid
      }

      :ok = Commanded.dispatch(create_user2_command, consistency: :strong)
      user2_projection = Repo.get_by!(UserProjection, uuid: user2_uuid)

      # Get first user projection
      user1_projection = Repo.get_by!(UserProjection, email: @valid_user_attrs.email)

      # Add first user as admin
      event1 = %UserAddedToTeam{
        team_uuid: team_projection.uuid,
        user_uuid: user1_projection.uuid,
        role: "admin"
      }

      # Add second user as member
      event2 = %UserAddedToTeam{
        team_uuid: team_projection.uuid,
        user_uuid: user2_projection.uuid,
        role: "member"
      }

      # Project both events
      :ok = TeamUserProjector.handle(event1, %{event_number: 1, handler_name: "team_users"})
      :ok = TeamUserProjector.handle(event2, %{event_number: 2, handler_name: "team_users"})

      # Verify both projections were created
      team_users =
        TeamUser
        |> where([tu], tu.team_uuid == ^team_projection.uuid)
        |> order_by([tu], tu.role)
        |> Repo.all()

      assert length(team_users) == 2

      admin_user = Enum.find(team_users, &(&1.role == "admin"))
      member_user = Enum.find(team_users, &(&1.role == "member"))

      assert admin_user.user_uuid == user1_projection.uuid
      assert member_user.user_uuid == user2_projection.uuid
    end

    test "handles user being added to multiple teams", %{
      user_projection: user_projection
    } do
      # Create second team via command dispatch
      team2_uuid = UUID.uuid4()

      create_team2_command = %CreateTeam{
        uuid: team2_uuid,
        name: "Team Two"
      }

      :ok = Commanded.dispatch(create_team2_command, consistency: :strong)
      team2_projection = Repo.get_by!(TeamProjection, uuid: team2_uuid)

      # Get first team projection
      team1_projection = Repo.get_by!(TeamProjection, name: @valid_team_attrs.name)

      # Add user to first team as admin
      event1 = %UserAddedToTeam{
        team_uuid: team1_projection.uuid,
        user_uuid: user_projection.uuid,
        role: "admin"
      }

      # Add user to second team as member
      event2 = %UserAddedToTeam{
        team_uuid: team2_projection.uuid,
        user_uuid: user_projection.uuid,
        role: "member"
      }

      # Project both events
      :ok = TeamUserProjector.handle(event1, %{event_number: 1, handler_name: "team_users"})
      :ok = TeamUserProjector.handle(event2, %{event_number: 2, handler_name: "team_users"})

      # Verify both projections were created
      team_users =
        TeamUser
        |> where([tu], tu.user_uuid == ^user_projection.uuid)
        |> order_by([tu], tu.role)
        |> Repo.all()

      assert length(team_users) == 2

      admin_membership = Enum.find(team_users, &(&1.role == "admin"))
      member_membership = Enum.find(team_users, &(&1.role == "member"))

      assert admin_membership.team_uuid == team1_projection.uuid
      assert member_membership.team_uuid == team2_projection.uuid
    end
  end
end
