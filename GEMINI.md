# GEMINI.md - AI Assistant Guide for the Reply Express API

This guide provides the necessary context for an AI assistant to effectively contribute to this project, ensuring it
adheres to our architecture and conventions.

## 1. Project Overview

This is the backend API for the Reply Express application, built with Elixir and Phoenix. It manages users, teams, and
related business logic using a CQRS/Event Sourcing architecture.

## 2. Core Technologies

- **Language:** Elixir
- **Web Framework:** Phoenix
- **Database:** PostgreSQL (using Ecto for projections)
- **CQRS/ES:** Commanded library
- **Event Store:** EventStore library with PostgreSQL persistence
- **Validation:** Vex
- **Test Factories:** ExMachina
- **Password Hashing:** Pbkdf2

## 3. Architecture: CQRS and Event Sourcing

This project **does not** use traditional MVC. It follows a strict CQRS/ES pattern. Understanding this is critical.

**Flow for State Changes:**

1. **Command:** A command is dispatched to represent an intent (e.g., `CreateUser`).
2. **Aggregate:** The command is handled by an Aggregate, which validates the command and emits one or more events.
3. **Event:** An event is persisted to the Event Store, representing a fact that has occurred (e.g., `UserCreated`).
4. **Projector:** A Projector listens for events and updates a read model (a denormalized Ecto schema) in the database.
5. **Projection (Read Model):** The updated Ecto schema that can be queried by the application.

**IMPORTANT:** When asked to add a feature that changes state, you MUST follow this CQRS/ES flow. Do not modify the
database directly from a controller.

## 4. Development Workflow

This project uses [mise](https://mise.jdx.dev/) for managing Elixir and Erlang versions. To run Elixir or Erlang commands, prepend `mise exec --`, for example, `mise exec -- mix test` or `mise exec -- iex -S mix phx.server`.

### Initial Setup

1. Copy the example config: `cp config/dev.local.example.exs config/dev.local.exs` (and fill in values)
2. Install dependencies and set up the database: `mix setup`

### Running the Application

- Start the Phoenix server: `mix phx.server`
- Start with an interactive shell: `iex -S mix phx.server`

### Database Management

- Reset both EventStore and Ecto (dev): `mix reset.dev`
- Reset both databases (test): `mix reset.test`
- Reset Ecto database only (dev): `mix ecto.reset`
- Reset EventStore only (dev): `mix eventstore.reset`

### Testing

- Run all tests: `mix test`
- Run a single test file: `mix test test/path/to/file_test.exs`
- Run only tests affected by recent changes: `mix test --stale`
- **Run tests with warnings as errors (mandatory for verification):** `mix test --warnings-as-errors`

### Code Quality

- Format all code: `mix format`
- Run the linter: `mix credo --strict`

## 5. Development Patterns

### Code Style

- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide).
- **Module Organization**: Following the `defmodule` statement, organize module elements as follows:
    - `@moduledoc`, then `use`, `import`, `alias` and `require`
    - `@type` statements
    - Module attributes, e.g., `@valid_credentials`
    - `defstruct` statement
    - All other elements
- **Ecto Queries**: Prefer keyword-based queries over pipe-based queries.
- **Aliases**: Use `alias` to shorten module names.

### Adding New Features (TDD is Mandatory)

1. **Specification:** Create or update a spec file in the `/specs` directory.
2. **Tests First:** Write tests before any implementation code.
3. **CQRS Implementation Order:**
    1. **Commands** in `lib/reply_express/accounts/commands/`
    2. **Events** in `lib/reply_express/accounts/events/`
    3. **Aggregates** in `lib/reply_express/accounts/aggregates/` (business logic)
    4. **Projectors** in `lib/reply_express/accounts/projectors/` (update read models)
    5. **Projections** in `lib/reply_express/accounts/projections/` (schema definitions)
    6. **Context** functions in respective context modules (public API)
    7. **Controllers** in `lib/reply_express_web/controllers/api/`
4. **Context:** Expose the functionality through the context module (e.g., `UsersContext`).

### Testing Patterns

- **Asserting on Results**: Prefer to assert on the result of a function call over matching on a pattern. Assign the
  result to a variable first, then assert on that variable.
- **Aggregate Tests (`AggregateCase`):** Test command-to-event flow in isolation.
- **Projector Tests (`DataCase`):** Test event-to-projection logic by calling the `handle/2` function directly with
  metadata.
- **Controller Tests (`ConnCase`):** Test the full HTTP request/response cycle.
- **Factories:** Use ExMachina factories from `test/support/factory.ex`.

**Projector Test Examples:**

**Method 1: Direct Handle Testing**

Test projectors by calling the `handle/2` method directly with proper metadata format:

```elixir
# Create test event
event = %UserAddedToTeam{
  team_uuid: team_uuid,
  user_uuid: user_uuid,
  role: "member"
}

# Call projector handle method with required metadata
:ok = TeamUserProjector.handle(event, %{
  event_number: 1,
  handler_name: "team_users"
})

# Verify projection was created in database
team_user = 
  TeamUser
  |> where([tu], tu.team_uuid == ^team_uuid and tu.user_uuid == ^user_uuid)
  |> Repo.one()

assert team_user.role == "member"
```

**Method 2: Integration Testing with Telemetry**

For integration tests that dispatch commands and wait for projections to complete:

```elixir
# 1. Add telemetry callback to projector
def after_update(event, metadata, changes) do
  :telemetry.execute(
    [:projector, :user],
    %{system_time: System.system_time()},
    %{event: event, metadata: metadata, changes: changes, projector: __MODULE__}
  )
end

# 2. Setup telemetry handler in test
setup do
  :telemetry.attach(
    "test-handler-user",
    [:projector, :user],
    fn event, measurements, metadata, reply_to ->
      send(reply_to, {:telemetry, event, measurements, metadata})
    end,
    self()
  )

  on_exit(fn -> :telemetry.detach("test-handler-user") end)
end

# 3. Test with synchronization
test "user projection is created" do
  user_uuid = UUID.uuid4()
  
  # Dispatch command
  :ok = Commanded.dispatch(create_user_command, consistency: :strong)
  
  # Wait for projection to complete
  assert_receive {:telemetry, [:projector, :user], _measurements, %{event: %UserCreated{uuid: ^user_uuid}}}
  
  # Now safe to assert on projection
  user = Repo.get_by(UserProjection, uuid: user_uuid)
  assert user.email == "test@example.com"
end
```

### Type Specifications

All modules and functions that represent public APIs and reusable data structures or define behaviours should include
`@type` and `@spec` definitions for clarity and static analysis.

## 6. API Design

- **Base Path:** `/api/v1/`
- **Authentication:** Session token-based.
- **Error Handling:** A central `FallbackController` handles errors and returns structured JSON responses (e.g., 422 for
  validation errors).

## 7. AI Assistant Workflow Rules

### 1. Planning Phase

- **Specification is Mandatory**: All features require a detailed specification in the `/specs` directory before any
  code is written. I will only create or edit spec files during this phase.
- **Approval**: The plan must be explicitly approved by you before I move to implementation.

### 2. Implementation Phase (TDD Workflow)

I will follow a strict, one-file-at-a-time process with explicit verification at each step.

- **Step 1: Write Test**: Write the test for a single component in a single file.
- **Step 2: Verify Test Fails**: Run the test to confirm it fails as expected. I will show you the expected failure.
- **Step 3: Implement Code**: Write the implementation code for that component to make the test pass.
- **Step 4: Verify Implementation Passes**: Run the tests again to confirm they pass.
- **Step 5: Code Quality Checks**: Run `mix format` and `mix credo --strict`.
- **Step 6: Get Your Verification**: I will present the completed file and wait for your explicit "OK" or "continue"
  before moving to the next file in the plan.

### 3. Verification Checklist

Before I ask for your final verification on a file, I will ensure:

- All tests for the file pass without warnings (`mix test --warnings-as-errors`).
- Code is formatted (`mix format`) and passes the linter (`mix credo --strict`).
- All modules and functions have `@moduledoc`, `@doc`, `@type`, and `@spec` definitions.
- The implementation matches the specification.
