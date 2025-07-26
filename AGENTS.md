# AGENTS.md - AI Assistant Guide for Reply Express API

This comprehensive guide is for AI agents working in this Elixir/Phoenix CQRS codebase. It consolidates essential information from project documentation to ensure consistent and effective development practices.

## Project Overview

This is the backend API for the Reply Express application, built with Elixir and Phoenix. It manages users, teams, and related business logic using a **CQRS/Event Sourcing architecture**.

### Core Technologies

- **Language:** Elixir
- **Web Framework:** Phoenix
- **Database:** PostgreSQL (using Ecto for projections)
- **CQRS/ES:** Commanded library
- **Event Store:** EventStore library with PostgreSQL persistence
- **Validation:** Vex
- **Test Factories:** ExMachina
- **Password Hashing:** Pbkdf2

## Essential Commands

This project uses [mise](https://mise.jdx.dev/) for managing Elixir and Erlang versions. To run Elixir or Erlang commands, prepend `mise exec --`, for example, `mise exec -- mix test` or `mise exec -- iex -S mix phx.server`.

### Development Setup

```bash
# Initial setup - copy config and install dependencies
cp config/dev.local.example.exs config/dev.local.exs  # Fill in values
mix setup                    # Install deps and setup databases
```

### Testing

```bash
mix test                                      # Run all tests
mix test test/path/to/specific_test.exs       # Run specific test file
mix test --warnings-as-errors                 # Run with strict warning checking
mix test --stale                              # Run only tests affected by recent changes
```

### Code Quality

```bash
mix credo --strict                            # Run strict static code analysis
mix format                                    # Format code
```

### Database Management

```bash
# Development Environment
mix reset.dev                                 # Reset both dev databases
mix ecto.reset                               # Reset Ecto database only
mix eventstore.reset                         # Reset EventStore only

# Test Environment
mix reset.test                                # Reset both test databases
# Or individually:
# MIX_ENV=test mix ecto.reset
# MIX_ENV=test mix eventstore.reset
```

### Development Server

```bash
mix phx.server                                # Start Phoenix server
iex -S mix phx.server                         # Start with interactive shell
```

## Architecture: CQRS and Event Sourcing

**CRITICAL:** This project does **NOT** use traditional MVC. It follows a strict CQRS/ES pattern.

### Flow for State Changes

1. **Command:** A command is dispatched to represent an intent (e.g., `CreateUser`)
2. **Aggregate:** The command is handled by an Aggregate, which validates the command and emits events
3. **Event:** An event is persisted to the Event Store, representing a fact that occurred (e.g., `UserCreated`)
4. **Projector:** A Projector listens for events and updates a read model (denormalized Ecto schema)
5. **Projection (Read Model):** The updated Ecto schema that can be queried by the application

**IMPORTANT:** When adding features that change state, you MUST follow this CQRS/ES flow. Do not modify the database directly from a controller.

### CQRS Implementation Order

Follow this sequence when implementing CQRS components:

1. **Commands:** `lib/reply_express/accounts/commands/`
2. **Events:** `lib/reply_express/accounts/events/`
3. **Aggregates:** `lib/reply_express/accounts/aggregates/` (business logic)
4. **Projectors:** `lib/reply_express/accounts/projectors/` (update read models)
5. **Projections:** `lib/reply_express/accounts/projections/` (schema definitions)
6. **Context functions:** in respective context modules (public API)
7. **Controllers:** `lib/reply_express_web/controllers/api/`
8. **JSON views:** for API responses

## Code Style & Patterns

### Style Guide

- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)

### Ecto Queries

- Prefer keyword-based queries over pipe-based queries
- Example: Use `User |> where(age: 18) |> select([u], u)` over `from(u in User, where: u.age > 18, select: u)`

### Module Organization

Following the `defmodule` statement, organize module elements as follows:

1. `@moduledoc`, then `use`, `import`, `alias` and `require`
2. `@type` statements
3. Module attributes, e.g., `@valid_credentials`
4. `defstruct` statement
5. All other elements

### Aliases

- Use `alias` to shorten module names
- Example: Use `alias ReplyExpress.Accounts.Projections.User` instead of the full module name

### Documentation & Typespecs

- Add `@moduledoc` and `@doc` attributes where appropriate
- Add `@type` and `@spec` definitions for modules and functions that represent public APIs and reusable data structures or that define behaviours
- Ensure comments are clear and helpful

## Workflow Rules

### 1. Planning Phase

- **Specification Creation:** All features require a detailed specification document in the `/specs` directory
  - Specifications should outline implementation details, API endpoints, commands, events, etc.
  - No code should be written until the specification is approved
  - Follow the existing pattern in other spec files
  - Include a detailed task list with clear dependencies between tasks

- **Task Dependency Documentation:**
  - Clearly document which tasks depend on others
  - For complex features, include a visual dependency graph or numbered sequence
  - Define task states: Not Started, In Progress, Implemented, Verified

- **Approval Process:** The plan must be explicitly approved before moving to implementation
  - Clarify any questions or concerns about the plan before implementation
  - Update the plan if any issues are discovered during review

### 2. Implementation Phase (TDD Workflow)

#### Test-First Development

- **TDD is mandatory:** Write tests *before* implementation code for each component
- Tests should be written one file at a time
- Ensure tests reflect the behavior described in the specification
- Run tests to verify they fail appropriately before implementation
- Document the expected failure to confirm the test is valid

#### Testing Best Practices

- **Assertion Rule:** Prefer to assert on the result of a function call over matching on a pattern
- Always assign the result of a function call to a variable first, then use assertions on that variable
- Run tests with `--warnings-as-errors` flag - tests must have no warnings or errors to be considered passing

```elixir
# INCORRECT: Pattern matching on function call within assertion
assert {:ok, user} = Users.create_user(params)

# CORRECT: Store result, then assert on it
result = Users.create_user(params)
assert {:ok, user} = result
```

#### Systematic File-by-File Approach

**Explicit Task Checkpoints:**
- ✅ Write test for feature
- ✅ Run test to verify it fails (expected failure)
- ✅ Implement feature
- ✅ Run test to verify it passes
- ✅ Perform code quality checks
- ✅ Get explicit verification before proceeding

**One-File-at-a-Time Implementation:**
- Complete one file entirely before moving to the next
- After implementing a file, verify it with the relevant test(s)
- Fix any issues before proceeding to the next file
- Get explicit verification before moving to the next file
- Never mark a task as complete until it passes all verification steps

#### Task State Definitions

- **Not Started:** Task has not been attempted
- **In Progress:** Tests written but implementation incomplete
- **Implemented:** Implementation complete but not verified
- **Verified:** Implementation verified with tests and review

#### Structured Verification Steps

Before marking a task complete, use this verification checklist:

1. **Test Verification:**
   - All tests for this file pass
   - Tests run without warnings
   - Tests are comprehensive (success and failure cases)
   - Test coverage is adequate

2. **Code Quality Checks:**
   - Run `mix credo --strict` with no issues
   - Run `mix format` to ensure proper formatting
   - Address all warnings - tests run with `--warnings-as-errors`
   - Code follows the Elixir Style Guide

3. **Documentation:**
   - Add appropriate documentation for modules and functions
   - Include @moduledoc and @doc attributes where appropriate
   - Add @type and @spec definitions for modules and functions that represent public APIs and reusable data structures or that define behaviours
   - Ensure comments are clear and helpful

4. **Functionality:**
   - All specified functionality is implemented
   - No regressions in existing functionality
   - Feature works as described in specification

## Communication Protocol

### Implementation Progress

- Verify with stakeholders after completing each file
- Clearly communicate the current task state (Not Started, In Progress, Implemented, Verified)
- Document any challenges or questions that arise during implementation

### Deviations from Plan

- If implementation needs to differ from the specification, discuss before proceeding
- Document reasons for deviation and get approval for changes

### Completion Checklist

Before finalizing a feature, ensure:
- All tests pass with no warnings
- Code follows style guide
- Documentation is complete
- All specified functionality is implemented
- All tasks have reached the "Verified" state

## Validation & Error Handling

- **Validation:** Use `Vex` for command validation
- **Error Handling:** Centralized in `FallbackController`. Validation errors return 422
- **Factories:** Use ExMachina factories from `test/support/factory.ex` for tests

## Key Reminders

- **Architecture First:** Always follow CQRS/ES patterns - never bypass the command/event flow
- **TDD Always:** Write tests before implementation, no exceptions
- **One File at a Time:** Complete and verify each file before moving to the next
- **Quality Gates:** All code must pass tests, credo, formatting, and documentation standards
- **Communication:** Get explicit verification before proceeding to next tasks
