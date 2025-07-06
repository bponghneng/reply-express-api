# Feature: Associate User with Team upon Registration

## Goal
When a new user registers, a process manager, within our Commanded CQRS architecture, will initiate a sequence of operations. This process will ensure the user is associated with a team. By default, if no other team association is specified (e.g., via an invitation), a personal team named "[User's Name]'s Team" will be created for the user, and they will be designated as its administrator.

## User Stories
- As a new user, upon completing my registration, I want the system to automatically create a personal team for me (e.g., "[My Name]'s Team") and assign me as its administrator, leveraging the CQRS pattern, so I can immediately begin organizing my work or inviting collaborators.
- As a system, when a `UserRegistered` event occurs, I want a process manager to orchestrate the creation of a default personal team and the association of the new user to this team as an admin, ensuring data consistency and clear event-driven flow.
- (Potentially, if still in scope for this initial phase) As a new user who has been invited to an existing team, I want my registration to automatically associate me with that specific team, handled through the CQRS process manager.
- (Potentially, if still in scope) As a new user, if I'm the first in my organization, I might want to specify a team name during registration, which then gets created with me as admin, all managed via CQRS commands and events.

## Proposed Changes

This feature will be implemented using a CQRS/ES approach with the Commanded library.

### 1. Commands
-   **`ReplyExpress.Accounts.Commands.RegisterUser`** (Existing)
    -   Data: `{uuid, email, hashed_password, ...}`
    -   Handled by: `ReplyExpress.Accounts.Aggregates.User`
-   **`ReplyExpress.Accounts.Commands.CreateTeam`** (Existing, but will require modification)
    -   Data: `{uuid, name, user_registration_uuid (optional)}`
    -   Handled by: `ReplyExpress.Accounts.Aggregates.Team`
    -   The `user_registration_uuid` will be added to the command as an optional field.
-   **`ReplyExpress.Accounts.Commands.AddUserToTeam`** (New)
    -   Data: `{team_uuid, user_uuid, role}`
    -   Handled by: `ReplyExpress.Accounts.Aggregates.Team`

### 2. Events
-   **`ReplyExpress.Accounts.Events.UserRegistered`** (Existing, but will require modification)
    -   Data: `{uuid, hashed_password, email, ...}`
    -   Published by: `ReplyExpress.Accounts.Aggregates.User`
-   **`ReplyExpress.Accounts.Events.TeamCreated`** (Existing, but will require modification)
    -   Data: `{uuid, name, user_registration_uuid}`
    -   Published by: `ReplyExpress.Accounts.Aggregates.Team`
    -   The `user_registration_uuid` will be added to the event.
-   **`ReplyExpress.Accounts.Events.UserAddedToTeam`** (New)
    -   Data: `{team_uuid, user_uuid, role}`
    -   Published by: `ReplyExpress.Accounts.Aggregates.Team`

### 3. Aggregates
-   **`ReplyExpress.Accounts.Aggregates.User`** (Existing)
    -   Handles `RegisterUser` command.
    -   Emits `UserRegistered` event.
-   **`ReplyExpress.Accounts.Aggregates.Team`** (Existing, but will require modification)
    -   Handles `CreateTeam` command, emits `TeamCreated` event.
    -   Will be modified to handle the new `AddUserToTeam` command.
    -   When handling `CreateTeam`, it will add the `user_registration_uuid` from the `UserRegistered` event to the emitted `TeamCreated` event.
    -   When handling `AddUserToTeam`, it will validate if the user can be added (e.g., not already a member) and then emit the `UserAddedToTeam` event.
    -   Its state will track team details (`uuid`, `name`) and a MapSet of member `user_id`s.

### 4. Process Manager
A new process manager, `ReplyExpress.Accounts.ProcessManagers.UserRegistration`, will orchestrate the flow:
-   **Starts** when it receives a `UserRegistered` event.
    -   State: Stores `user_uuid`, `email` from the event.
-   **Handles `UserRegistered` event:**
    -   Dispatches a `CreateTeam` command.
        -   `team_uuid` will be a newly generated UUID.
        -   `name` will be derived from the user's email address (e.g., "test@example.com" → "Test's Team").
        -   `user_registration_uuid` will be the `user_uuid` from the process manager state.
-   **Listens for `TeamCreated` event** (where `user_registration_uuid` matches the process manager's stored `user_uuid`).
    -   State: Stores `team_uuid` from the event.
-   **Handles `TeamCreated` event:**
    -   Dispatches an `AddUserToTeam` command.
        -   `team_uuid` will be the `team_uuid` from the `TeamCreated` event.
        -   `user_uuid` will be the `user_uuid` stored in the process manager.
        -   `role` will be "admin".
-   **Listens for `UserAddedToTeam` event** (where `team_uuid` and `user_uuid` match those stored).
    -   Marks the process as complete for this user registration instance. The process manager instance can then be stopped or archived.

The process manager's state will need to be defined (e.g., `defstruct [:user_uuid, :email, :team_uuid, :status]`).
It will implement `interested?/1` to route events and `handle/2` and `apply/2` for command dispatch and state mutation, similar to the `Commanded.ProcessManagers.ProcessManager` documentation.

#### Supervisor Configuration
The new process manager must be added to `ReplyExpress.Accounts.Supervisor` to be started and managed by the OTP supervision tree, as required by Commanded.

-   **File:** `lib/reply_express/accounts/supervisor.ex`
-   **Update:** Add `UserRegistration` and `TeamUserProjector` to the children list.
-   **Example implementation:**
    ```elixir
    # In lib/reply_express/accounts/supervisor.ex
    alias ReplyExpress.Accounts.ProcessManagers.UserRegistration
    alias ReplyExpress.Accounts.Projectors.TeamUserProjector

    def init(_arg) do
      Supervisor.init([
        TeamProjector, 
        UserProjector, 
        UserTokenProjector,
        TeamUserProjector,  # Add the new projector
        UserRegistration    # Add the new process manager
      ], strategy: :one_for_one)
    end
    ```

### 5. Projections (Read Models)
Projections will be updated by event handlers listening to the events above. These will populate Ecto schemas for querying.
-   **`ReplyExpress.Accounts.Projections.User`** (Existing, needs update)
    -   Handler listens to: `UserAddedToTeam`.
    -   Updates: Adds the `team_uuid` to a list of associated teams for the user (or similar denormalized reference).
-   **`ReplyExpress.Accounts.Projections.Team`** (Existing, needs update)
    -   Handler listens to: `TeamCreated`, `UserAddedToTeam`.
    -   Updates: Creates/updates team details. May store a list of `user_uuid`s that are members.
-   **`ReplyExpress.Accounts.Projections.TeamUser`** (New - serves as the "join table" read model)
    -   Handler listens to: `UserAddedToTeam`.
    -   Updates: Creates a record linking `user_uuid` and `team_uuid` with the `role`.
    -   Includes validation to ensure both team and user exist before creating the association.

### 6. API Endpoint (`POST /api/users/register`)
-   The existing registration API endpoint will dispatch the `RegisterUser` command as it likely already does.
-   The rest of the team association logic will be handled asynchronously by the process manager triggered by the subsequent `UserRegistered` event.
-   The API response for user registration will not need to wait for team creation/association to complete.

### 7. Context and Router Updates

#### `ReplyExpress.Accounts.TeamsContext`
The existing team context will be updated to provide a public function for adding users to teams.

-   **New Function:** `add_user_to_team/1`
    -   Accepts a single `attrs` map with string keys: `"role"`, `"team_uuid"`, and `"user_uuid"`.
    -   Validates the attributes using the `AddUserToTeam` command validation.
    -   Dispatches the `AddUserToTeam` command and returns the updated team with preloaded associations.
    -   Returns `{:ok, team}` on success, or `{:error, :validation_failure, errors}` on validation failure.
    -   Example implementation:
        ```elixir
        # In lib/reply_express/accounts/teams_context.ex
        alias ReplyExpress.Accounts.Commands.AddUserToTeam

        @doc """
        Adds a user to a team.
        
        Returns `{:ok, team}` on success, or `{:error, reason}` on failure.
        """
        def add_user_to_team(attrs) do
          add_user_to_team_command =
            attrs
            |> AddUserToTeam.new()
            |> AddUserToTeam.set_team_id(attrs["team_uuid"])
            |> AddUserToTeam.set_user_id(attrs["user_uuid"])
            |> AddUserToTeam.set_role(attrs["role"])

          with :ok <- Commanded.dispatch(add_user_to_team_command, consistency: :strong) do
            case team_by_uuid(attrs["team_uuid"]) do
              nil -> {:error, :not_found}
              team -> {:ok, team}
            end
          end
        end
        ```

-   **Updated Function:** `team_by_uuid/1`
    -   Updated to preload the `team_users` association with nested `user` association.
    -   Example implementation:
        ```elixir
        @doc """
        Gets a team by UUID with preloaded team_users and users.
        
        Returns the team if found, or `nil` if not found.
        """
        def team_by_uuid(uuid) do
          Repo.one(from t in TeamProjection, 
            where: t.uuid == ^uuid,
            preload: [team_users: :user]
          )
        end
        ```

#### `ReplyExpressWeb.Router`
The router will be updated to add the new endpoint for adding a user to a team, maintaining consistency with the existing flat structure.

-   A new route `POST /teams/:id/add-user` will be added alongside the existing `POST /teams` route.
-   This will require a corresponding `add_user/2` action in the `TeamsController`.

Example router configuration:
```elixir
# In lib/reply_express_web/router.ex
scope path: "/api/v1", alias: ReplyExpressWeb.API.V1 do
  pipe_through [:api]

  scope path: "/users", alias: Users do
    # ... existing user routes
  end

  # Teams endpoints (maintaining flat structure)
  post "/teams", TeamsController, :create
  post "/teams/:uuid/add-user", TeamsController, :add_user
end
```

#### `TeamsController.add_user/2`
The `TeamsController` will be updated to include a new action, `add_user/2`, to handle the `POST /teams/:uuid/add-user` route. 

This action will be responsible for adding a user to a team. It will receive the team's UUID from the URL (`:id`) and the `user_uuid` and `role` from the request body.

- **Action:** `add_user/2`
  - **Purpose:** To add a user to a team with a specified role.
  - **URL:** `/api/v1/teams/:uuid/add-user`
  - **Method:** `POST`
  - **Params:** The team's UUID is expected as `:uuid` in the URL path. The request body should contain the `user_uuid` and `role`.
  - **Success Response:** On successful addition of the user to the team, the response will be `200 OK` with the updated team data.
  - **Error Response:** If there are validation errors or the addition fails, the response will be `422 Unprocessable Entity` with error details.

Example implementation in `TeamsController`:
```elixir
defmodule ReplyExpressWeb.API.V1.TeamsController do
  use ReplyExpressWeb, :controller

  # ... existing actions

  @doc """
  Adds a user to a team.
  """
  def add_user(conn,  params) do
    with {:ok, team} <- TeamsContext.add_user_to_team(params) do
      conn
      |> put_status(:ok)
      |> render("show.json", team: team)
    else
      {:error, :validation_failure, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})
    end
  end
end
```

#### ReplyExpressWeb.API.V1.TeamsJSON
The `TeamsJSON` view will be updated to render the list of users associated with a team. This involves adding a `team_users` key to the response, which will be a list of maps, each containing a user's `uuid`, `email`, and their `role` within the team.

A new `show/1` function will be added to handle rendering for the `add_user` action, and the `data/1` function will be updated to format the `team_users` data.

-   **File:** `lib/reply_express_web/views/api/v1/teams_json.ex`
-   **Update:**
    -   Add a `show/1` function that renders a single team.
    -   Update `data/1` to include the `team_users` list.
    -   Each user in the list will have `uuid`, `email`, and `role`.

Example implementation:
```elixir
defmodule ReplyExpressWeb.API.V1.TeamsJSON do
  @moduledoc """
  Renders JSON for team-related responses.
  """
  alias ReplyExpress.Accounts.Projections.Team, as: TeamProjection
  alias ReplyExpress.Accounts.Projections.TeamUser, as: TeamUserProjection

  def create(%{team: team}), do: %{data: data(team)}
  def show(%{team: team}), do: %{data: data(team)}

  defp data(%TeamProjection{team_users: team_users} = team) do
    %{
      uuid: team.uuid,
      name: team.name,
      team_users: Enum.map(team_users, &format_team_user/1)
    }
  end

  defp format_team_user(%TeamUserProjection{user: user, role: role}) do
    %{uuid: user.uuid, email: user.email, role: role}
  end
end
```

### 8. Testing Strategy (TDD Approach)
To ensure the reliability and correctness of this feature, we will follow a test-driven development approach. Tests will be written before the implementation code for each component.

#### a. Aggregate Tests (`Team` Aggregate)
-   **File:** `test/reply_express/accounts/aggregates/team_test.exs`
-   **Scenario:** Handling the `CreateTeam` command for duplicate team.
    -   **Given:** An existing team.
    -   **When:** A `CreateTeam` command is dispatched with the same UUID.
    -   **Then:** The command is rejected (returns `{:error, :team_already_exists}`).
-   **Scenario:** Handling the `AddUserToTeam` command.
    -   **Given:** An existing team.
    -   **When:** The `AddUserToTeam` command is dispatched.
    -   **Then:** An `UserAddedToTeam` event is produced.
-   **Scenario:** Attempting to add a user who is already in the team.
    -   **Given:** An existing team with a user.
    -   **When:** The `AddUserToTeam` command is dispatched for the same user.
    -   **Then:** The command is rejected (returns an error).
-   **Note:** Validation scenarios (user existence, invalid roles) are tested at the Context level in `TeamsContext.add_user_to_team/1` tests, not in the aggregate. Duplicate team creation validation should be implemented at both the CreateTeam command level (for early validation) and the Team aggregate level (for business rule enforcement).

#### b. Process Manager Tests (`UserRegistration` Process Manager)
-   **File:** `test/reply_express/accounts/process_managers/user_registration_test.exs` (New file)
-   **Testing `interested?/1`:**
    -   **Scenario:** The process manager should only be interested in relevant events.
        -   **Given:** A `UserRegistered` event.
        -   **Then:** `interested?/1` should return `{:start, user_uuid}`.
        -   **Given:** A `TeamCreated` event with the `user_registration_uuid` matching the process manager's stored `user_uuid`.
        -   **Then:** `interested?/1` should return `{:continue, user_uuid}`.
        -   **Given:** A `UserAddedToTeam` event with the `team_uuid` and `user_uuid` matching those stored.
        -   **Then:** `interested?/1` should return `{:stop, user_uuid}`.
        -   **Given:** An unrelated event (e.g., `UnrelatedEvent`).
        -   **Then:** `interested?/1` should return `false`.
-   **Testing `handle/2`:**
    -   **Scenario:** Handling `UserRegistered` event.
        -   **Given:** A `UserRegistered` event and an initial state.
        -   **When:** `handle/2` is called.
        -   **Then:** It should dispatch a `CreateTeam` command.
    -   **Scenario:** Handling `TeamCreated` event.
        -   **Given:** A `TeamCreated` event with the `user_registration_uuid` matching the process manager's stored `user_uuid` and a state containing the `user_uuid`.
        -   **When:** `handle/2` is called.
        -   **Then:** It should dispatch an `AddUserToTeam` command.
-   **Testing `apply/2`:**
    -   **Scenario:** Applying `UserRegistered` event.
        -   **Given:** A `UserRegistered` event and an initial state.
        -   **When:** `apply/2` is called.
        -   **Then:** The new state should contain the `user_uuid` and `email`.
    -   **Scenario:** Applying `TeamCreated` event.
        -   **Given:** A `TeamCreated` event and the current state.
        -   **When:** `apply/2` is called.
        -   **Then:** The new state should contain the `team_uuid`.
-   **Scenario:** End-to-end successful flow.
    -   **Given:** A `UserRegistered` event.
    -   **Expect:** A `CreateTeam` command to be dispatched.
    -   **Given:** A subsequent `TeamCreated` event.
    -   **Expect:** An `AddUserToTeam` command to be dispatched.
    -   **Given:** A subsequent `UserAddedToTeam` event.
    -   **Expect:** The process to be complete.

#### c. Projection Tests (`TeamUser` Projector)
-   **File:** `test/reply_express/accounts/projectors/team_user_projector_test.exs`
-   **Scenario:** A user is added to a team.
    -   **Given:** A `UserAddedToTeam` event.
    -   **When:** The event is handled by the `TeamUserProjector`.
    -   **Then:** A new `TeamUser` record is created in the database with the correct `user_uuid`, `team_uuid`, and `role`.
-   **Scenario:** Multiple users and teams.
    -   **Given:** Multiple `UserAddedToTeam` events for different users and teams.
    -   **When:** The events are handled by the `TeamUserProjector`.
    -   **Then:** All `TeamUser` records are created correctly with proper associations.

#### d. Context Tests (TeamsContext.add_user_to_team/1)
-   **File:** `test/reply_express/accounts/teams_context_test.exs`
-   **Scenario:** Adding a user to a team successfully.
    -   **Given:** A valid team and user exist.
    -   **When:** `TeamsContext.add_user_to_team/1` is called with valid attributes.
    -   **Then:** The function returns `{:ok, team}`.
-   **Scenario:** Adding a user with admin role.
    -   **Given:** A valid team and user exist.
    -   **When:** `TeamsContext.add_user_to_team/1` is called with role "admin".
    -   **Then:** The function returns `{:ok, team}`.
-   **Scenario:** Attempting to add the same user twice to a team.
    -   **Given:** A team with an existing user.
    -   **When:** `TeamsContext.add_user_to_team/1` is called for the same user again.
    -   **Then:** The function returns `{:error, :validation_failure, errors}`.
-   **Scenario:** Attempting to add a user with invalid role.
    -   **Given:** A valid team and user exist.
    -   **When:** `TeamsContext.add_user_to_team/1` is called with an invalid role.
    -   **Then:** The function returns `{:error, :validation_failure, errors}`.
-   **Scenario:** Validation failure for missing team_uuid.
    -   **When:** `TeamsContext.add_user_to_team/1` is called without team_uuid.
    -   **Then:** The function returns `{:error, :validation_failure, errors}`.
-   **Scenario:** Validation failure for missing user_uuid.
    -   **When:** `TeamsContext.add_user_to_team/1` is called without user_uuid.
    -   **Then:** The function returns `{:error, :validation_failure, errors}`.
-   **Scenario:** Validation failure for missing role.
    -   **When:** `TeamsContext.add_user_to_team/1` is called without role.
    -   **Then:** The function returns `{:error, :validation_failure, errors}`.

#### e. Integration Tests (API Endpoint)
-   **File:** `test/reply_express_web/controllers/api/v1/teams_controller_test.exs`
-   **Scenario:** Adding a user to a team via the API.
    -   **When:** A `POST` request is made to `/api/v1/teams/:id/add-user` with a valid payload.
    -   **Then:** The response is successful (e.g., `200 OK`).
    -   **And:** The `TeamsContext.add_user_to_team/1` function is called successfully.
-   **Scenario:** API validation errors.
    -   **When:** A `POST` request is made with invalid or missing data.
    -   **Then:** The response returns appropriate validation errors (e.g., `422 Unprocessable Entity`).

## Design Decisions

### Process Manager Failure Handling
For the initial implementation, the process manager will rely on Commanded's default error handling. If a command dispatch fails (e.g., `CreateTeam` or `AddUserToTeam`), the specific process manager instance will halt, and the failure will be logged. A more robust retry mechanism (e.g., with exponential backoff) can be considered as a future enhancement.

### API Endpoint Details (`POST /:id/add-user`)

#### Request Body
The endpoint will expect a JSON request body containing the UUID of the user to be added and their role. The team's UUID is provided in the URL.

-   **URL:** `/api/v1/teams/:team_uuid/add-user`
-   **Body:**
    ```json
    {
      "user_uuid": "...",
      "role": "member"
    }
    ```

## Acceptance Criteria
- When a new user registers, a `UserRegistered` event is published.
- The `UserRegistration` process manager successfully starts upon receiving the `UserRegistered` event.
- The process manager dispatches a `CreateTeam` command, which results in a `TeamCreated` event.
- The process manager then dispatches an `AddUserToTeam` command with the role "admin", resulting in a `UserAddedToTeam` event.
- The `TeamUser` projection is updated with a new record linking the `user_uuid` and the new `team_uuid` with the role "admin".
- A `POST` request to `/api/v1/teams/:id/add-user` with a valid `user_uuid` and `role` successfully dispatches an `AddUserToTeam` command.
- The `Team` aggregate correctly handles the `AddUserToTeam` command and emits a `UserAddedToTeam` event.
- The `TeamUser` projection is correctly updated when a user is added via the API endpoint.
