# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Essential Commands

### Development Setup

```bash
# Initial setup - copy config and install dependencies
cp config/dev.local.example.exs config/dev.local.exs  # Fill in values
mix setup                    # Install deps and setup databases
```

### Development Server

```bash
mix phx.server              # Start server (port 4000)
iex -S mix phx.server      # Start with interactive Elixir shell
```

### Testing

```bash
mix test                   # Run full test suite
mix test test/path/to/specific_test.exs  # Run single test file
mix test --stale          # Run only tests affected by recent changes
```

### Database Management

```bash
# Development environment
mix reset.dev             # Reset both EventStore and Ecto database
mix ecto.reset           # Reset only Ecto database
mix eventstore.reset     # Reset only EventStore

# Test environment
mix reset.test           # Reset both databases for tests
```

### Code Quality

```bash
mix credo                # Run static code analysis
mix format              # Format code
```

## Architecture Overview

This is a **CQRS/Event Sourcing API** built with Elixir/Phoenix using the Commanded library. The application implements pure event-driven architecture with clear separation between commands (write) and queries (read).

### Core Patterns

**CQRS/Event Sourcing Flow:**

1. HTTP Request → Controller → Context
2. Context → Command dispatch via Commanded
3. Aggregate processes command → Emits events
4. Projectors handle events → Update read models
5. Query read models for responses

**Domain Structure:**

```
lib/reply_express/accounts/    # Main bounded context
├── aggregates/               # Business logic (User, Team, UserToken)
├── commands/                # Intent to change state
├── events/                  # Immutable facts
├── projections/            # Read model schemas (Ecto)
├── projectors/             # Event → Projection transformers
├── queries/                # Query objects for read models
├── validators/             # Business rule validations
└── *_context.ex           # Public domain API
```

### Key Technologies

- **Commanded (~> 1.4)**: CQRS/Event Sourcing framework
- **EventStore + PostgreSQL**: Dual persistence (events + projections)
- **Vex**: Command validation
- **ExMachina**: Test factories
- **Pbkdf2**: Password hashing

## Development Patterns

### Adding New Features

1. **Create Specification**: Add to `/specs/` directory following existing patterns
2. **Follow CQRS Pattern**:
   - Command in `commands/`
   - Events in `events/`
   - Aggregate logic in `aggregates/`
   - Projector in `projectors/`
   - Projection schema in `projections/`
   - Context function for public API
3. **Add Controller**: HTTP interface in `lib/reply_express_web/`
4. **Add Tests**: Mirror lib structure in test directory

### Testing Approach

- **Aggregate Tests**: Use `AggregateCase` to test command → event flows
- **Context Tests**: Test public domain API functions
- **Controller Tests**: Use `ConnCase` for HTTP endpoint testing
- **Projector Tests**: Test event projections using `DataCase` and direct handle calls
- **Factories**: Use ExMachina factories in `test/support/factory.ex`

### Projector Testing Patterns

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

**Key Requirements:**
- Use `DataCase` for database access
- **Method 1:** Call `ProjectorModule.handle(event, metadata)` with correct metadata format
- **Method 2:** Use telemetry to wait for projections to complete before assertions
- Metadata must include `event_number` and `handler_name` keys (Method 1)
- Verify projections by querying the database directly

**When to Use Each Method:**
- **Method 1:** Unit testing projector logic in isolation
- **Method 2:** Integration testing with command dispatch and asynchronous event processing

**Reference:** [Testing read model projectors - Commanded Recipes](https://github.com/commanded/recipes/issues/18)

### Test Factories

**Available Command Factories:**

```elixir
# In lib/reply_express/factory.ex
build(:cmd_register_user)                   # RegisterUser command
build(:cmd_create_team)                     # CreateTeam command
build(:cmd_login)                           # Login command
build(:cmd_clear_user_tokens)               # ClearUserTokens command
build(:cmd_generate_password_reset_token)   # GeneratePasswordResetToken command
build(:cmd_reset_password)                  # ResetPassword command
build(:cmd_start_user_session)              # StartUserSession command

# Override defaults
build(:cmd_register_user, %{"password" => "custom"})
build(:cmd_create_team, name: "Custom Team")
build(:cmd_login, email: "user@example.com")
```

**Factory Testing Pattern:**

- Each factory has its own `describe` block in `test/reply_express/factory_test.exs`
- Tests verify both default values and attribute overrides
- Use assertion pattern: `assert result.field == expected_value`

### Command Validation

Commands use Vex for validation. Custom validators are in `accounts/validators/`:

- Database validations (unique_email, valid_user_uuid)
- Business rule validations (logged_in_at_not_expired)
- Cross-aggregate validations (reset_password_token_exists)

### Database Considerations

**Dual Persistence Model:**

- **EventStore**: Immutable event log (source of truth)
- **PostgreSQL**: Optimized projections for queries
- **Migrations**: Only for projection schemas (not events)

Both databases must be managed separately - use `mix reset.dev` to reset both.

## API Design

**Base Path**: `/api/v1/`

**Authentication**: Session token-based (stored as projections)

**Error Handling**: Centralized via `FallbackController`

- Validation errors → 422 with field details
- Command errors → Structured JSON responses

## Type Specifications

All modules should include comprehensive `@type` specifications. This codebase follows strict typing practices for better documentation and tooling support.

## Development Guidelines

### Workflow Rules

- **Planning Phase:** When you say you want to create a plan, I will *only* create or edit a plan file in the `specs/` directory. I will not make any other changes to the codebase until you approve the plan.
- **Implementation Phase:** When implementing a plan, I will work on one file at a time. After I have written the code for a file, I will verify with you before beginning work on the next file.
- **TDD is mandatory.** Write tests *before* implementation. All new features require a spec in `/specs`.

### Implementation Workflow

When implementing features from plans in `/specs`, follow this systematic approach:

#### 1. **Pre-Implementation Analysis**
- Read and understand the complete plan
- Identify what tests already exist vs. what needs to be created
- Update the plan with any differences found in existing tests
- Create a prioritized todo list of all implementation tasks

#### 2. **One-File-at-a-Time Implementation**
- Work on only **one file at a time**
- For each file:
  1. **Run the relevant test first** to see current errors and understand requirements
  2. **Fix test issues** if tests have problems (incorrect setup, wrong expectations, etc.)
  3. **Implement the file** to make the tests pass
  4. **Run tests again** to verify implementation works
  5. **Fix any warnings** (unused variables, duplicate docs, etc.)
  6. **Update the plan** if implementation details differ from original plan

#### 3. **Test-First Approach**
- Always run tests before implementing to understand what's needed
- Fix test problems before implementation problems
- Ensure tests accurately reflect the planned behavior
- Remove or fix tests that don't align with architecture (e.g., wrong event handling)

#### 4. **Plan Maintenance**
- Update specs when implementation differs from original plan
- Document architectural decisions made during implementation
- Keep todo lists updated with progress and new discoveries

#### 5. **Quality Gates**
- All tests must pass before moving to next file
- All warnings must be resolved
- Documentation must be updated for any changes

### Specification and Implementation Workflow

- **All plans should be stored in the `specs` directory.**
- **Implement features using a test-driven development (TDD) approach.**
  - Write the tests first, one file at a time.
  - Do not write any implementation before tests.
  - Verify that every test file is correct before writing the next one.

### Implementation Best Practices

- **When implementing a plan with existing tests, write one file at a time. When the file is written, run the test and fix any errors before continuing to write the next file.**
- **Typespecs:** All modules and functions must have `@type` and `@spec` definitions.
