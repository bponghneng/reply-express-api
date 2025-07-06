defmodule ReplyExpress.Accounts.ProcessManagers.UserRegistrationTest do
  @moduledoc false

  use ExUnit.Case

  alias ReplyExpress.Accounts.Commands.AddUserToTeam
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Events.TeamCreated
  alias ReplyExpress.Accounts.Events.UserAddedToTeam
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.ProcessManagers.UserRegistration

  describe "interested?/1" do
    test "starts process on UserRegistered event" do
      user_uuid = UUID.uuid4()

      event = %UserRegistered{
        uuid: user_uuid,
        email: "test@example.com",
        hashed_password: "hashed_password"
      }

      assert UserRegistration.interested?(event) == {:start, user_uuid}
    end

    test "continues process on TeamCreated event with matching user_registration_uuid" do
      user_uuid = UUID.uuid4()
      team_uuid = UUID.uuid4()

      event = %TeamCreated{
        uuid: team_uuid,
        name: "Test User's Team",
        user_registration_uuid: user_uuid
      }

      assert UserRegistration.interested?(event) == {:continue, user_uuid}
    end

    test "stops process on UserAddedToTeam event with matching identifiers" do
      user_uuid = UUID.uuid4()
      team_uuid = UUID.uuid4()

      event = %UserAddedToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "admin"
      }

      assert UserRegistration.interested?(event) == {:stop, user_uuid}
    end

    test "returns false for unrelated events" do
      unrelated_event = %{some_field: "some_value"}

      assert UserRegistration.interested?(unrelated_event) == false
    end
  end

  describe "handle/2" do
    test "handles UserRegistered event by dispatching CreateTeam command" do
      user_uuid = UUID.uuid4()

      event = %UserRegistered{
        uuid: user_uuid,
        email: "test@example.com",
        hashed_password: "hashed_password"
      }

      state = %UserRegistration{
        user_uuid: nil,
        email: nil,
        team_uuid: nil,
        status: nil
      }

      result = UserRegistration.handle(state, event)

      assert result.__struct__ == CreateTeam
      assert result.uuid != user_uuid
      assert result.name == "Test's Team"
      assert result.user_registration_uuid == user_uuid
    end

    test "handles TeamCreated event by dispatching AddUserToTeam command" do
      user_uuid = UUID.uuid4()
      team_uuid = UUID.uuid4()

      event = %TeamCreated{
        uuid: team_uuid,
        name: "Test User's Team",
        user_registration_uuid: user_uuid
      }

      state = %UserRegistration{
        user_uuid: user_uuid,
        email: "test@example.com",
        team_uuid: nil,
        status: :team_creation_requested
      }

      expected_command = %AddUserToTeam{
        team_uuid: team_uuid,
        user_uuid: user_uuid,
        role: "admin"
      }

      result = UserRegistration.handle(state, event)

      assert result == expected_command
    end
  end

  describe "apply/2" do
    test "applies UserRegistered event to update state" do
      user_uuid = UUID.uuid4()

      event = %UserRegistered{
        uuid: user_uuid,
        email: "test@example.com",
        hashed_password: "hashed_password"
      }

      initial_state = %UserRegistration{
        user_uuid: nil,
        email: nil,
        team_uuid: nil,
        status: nil
      }

      expected_state = %UserRegistration{
        user_uuid: user_uuid,
        email: "test@example.com",
        team_uuid: nil,
        status: :team_creation_requested
      }

      result = UserRegistration.apply(initial_state, event)

      assert result == expected_state
    end

    test "applies TeamCreated event to update state" do
      user_uuid = UUID.uuid4()
      team_uuid = UUID.uuid4()

      event = %TeamCreated{
        uuid: team_uuid,
        name: "Test User's Team",
        user_registration_uuid: user_uuid
      }

      state = %UserRegistration{
        user_uuid: user_uuid,
        email: "test@example.com",
        team_uuid: nil,
        status: :team_creation_requested
      }

      expected_state = %UserRegistration{
        user_uuid: user_uuid,
        email: "test@example.com",
        team_uuid: team_uuid,
        status: :user_addition_requested
      }

      result = UserRegistration.apply(state, event)

      assert result == expected_state
    end
  end

  describe "end-to-end process flow" do
    test "complete user registration team association flow" do
      user_uuid = UUID.uuid4()
      team_uuid = UUID.uuid4()

      initial_state = %UserRegistration{
        user_uuid: nil,
        email: nil,
        team_uuid: nil,
        status: nil
      }

      # Step 1: User registers
      user_registered = %UserRegistered{
        uuid: user_uuid,
        email: "test@example.com",
        hashed_password: "hashed_password"
      }

      # Step 2: Process starts and should dispatch CreateTeam
      create_team_command =
        UserRegistration.handle(initial_state, user_registered)

      assert %CreateTeam{} = create_team_command
      assert create_team_command.name == "Test's Team"
      assert create_team_command.user_registration_uuid == user_uuid

      # Apply UserRegistered event
      state_after_user_registered =
        UserRegistration.apply(initial_state, user_registered)

      assert state_after_user_registered.user_uuid == user_uuid
      assert state_after_user_registered.email == "test@example.com"
      assert state_after_user_registered.status == :team_creation_requested

      # Step 3: Team is created
      team_created = %TeamCreated{
        uuid: team_uuid,
        name: "Test User's Team",
        user_registration_uuid: user_uuid
      }

      # Handle TeamCreated event - should add user to team command
      add_user_command = UserRegistration.handle(state_after_user_registered, team_created)

      assert %AddUserToTeam{} = add_user_command
      assert add_user_command.team_uuid == team_uuid
      assert add_user_command.user_uuid == user_uuid
      assert add_user_command.role == "admin"

      # Apply TeamCreated event
      state_after_team_created = UserRegistration.apply(state_after_user_registered, team_created)

      assert state_after_team_created.team_uuid == team_uuid
      assert state_after_team_created.status == :user_addition_requested
    end
  end
end
