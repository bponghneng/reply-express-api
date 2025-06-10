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
- **Factories**: Use ExMachina factories in `test/support/factory.ex`

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

## AI Workflow Integration

This project includes Python-based AI development workflows in `/workflows/`:
- Specification-driven development using markdown specs
- `new_endpoint.py` for automated endpoint generation
- Integration with Aider AI assistant