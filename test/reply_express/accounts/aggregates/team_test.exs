defmodule ReplyExpress.Accounts.Aggregates.TeamTest do
  @moduledoc false

  use ReplyExpress.AggregateCase, aggregate: ReplyExpress.Accounts.Aggregates.Team

  alias ReplyExpress.Accounts.Commands.AddUserToTeam
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Events.TeamCreated
  alias ReplyExpress.Accounts.Events.UserAddedToTeam

  describe "CreateTeam command" do
    test "creates a team with user_uuid" do
      team_uuid = UUID.uuid4()
      user_uuid = UUID.uuid4()
      
      command = %CreateTeam{
        uuid: team_uuid,
        name: "Test Team",
        user_registration_uuid: user_uuid
      }

      expected_event = %TeamCreated{
        uuid: team_uuid,
        name: "Test Team",
        user_registration_uuid: user_uuid
      }

      assert_events(command, [expected_event])
    end

    test "prevents creating a team when team already exists" do
      team_uuid = UUID.uuid4()
      user_uuid = UUID.uuid4()
      
      _create_command = %CreateTeam{
        uuid: team_uuid,
        name: "Test Team",
        user_registration_uuid: user_uuid
      }

      created_event = %TeamCreated{
        uuid: team_uuid,
        name: "Test Team", 
        user_registration_uuid: user_uuid
      }

      duplicate_command = %CreateTeam{
        uuid: team_uuid,
        name: "Another Team",
        user_registration_uuid: user_uuid
      }

      assert_error([created_event], duplicate_command, {:error, :team_already_exists})
    end
  end

  describe "AddUserToTeam command" do
    test "adds a user to an existing team" do
      team_uuid = UUID.uuid4()
      user_uuid = UUID.uuid4()
      creating_user_uuid = UUID.uuid4()

      # Create the team
      team_created_event = %TeamCreated{
        uuid: team_uuid,
        name: "Test Team",
        user_registration_uuid: creating_user_uuid
      }

      # Then add a user to the team
      command = %AddUserToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "member"
      }

      expected_event = %UserAddedToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "member"
      }

      assert_events([team_created_event], command, [expected_event])
    end

    test "adds a user as admin to an existing team" do
      team_uuid = UUID.uuid4()
      user_uuid = UUID.uuid4()
      creating_user_uuid = UUID.uuid4()

      team_created_event = %TeamCreated{
        uuid: team_uuid,
        name: "Test Team",
        user_registration_uuid: creating_user_uuid
      }

      command = %AddUserToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "admin"
      }

      expected_event = %UserAddedToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "admin"
      }

      assert_events([team_created_event], command, [expected_event])
    end

    test "prevents adding a user to a non-existent team" do
      team_uuid = UUID.uuid4()
      user_uuid = UUID.uuid4()

      command = %AddUserToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "member"
      }

      assert_error([], command, {:error, :team_not_found})
    end


    test "prevents adding a user who is already a team member" do
      team_uuid = UUID.uuid4()
      user_uuid = UUID.uuid4()
      creating_user_uuid = UUID.uuid4()

      team_created_event = %TeamCreated{
        uuid: team_uuid,
        name: "Test Team",
        user_registration_uuid: creating_user_uuid
      }

      user_added_event = %UserAddedToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "member"
      }

      duplicate_command = %AddUserToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "admin"
      }

      assert_error(
        [team_created_event, user_added_event],
        duplicate_command,
        {:error, :user_already_member}
      )
    end

  end
end