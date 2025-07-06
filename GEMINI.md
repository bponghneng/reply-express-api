# GEMINI.md - AI Assistant Guide for the Reply Express API

This guide provides the necessary context for an AI assistant to effectively contribute to this project, ensuring it adheres to our architecture and conventions.

## 1. Project Overview

This is the backend API for the Reply Express application, built with Elixir and Phoenix. It manages users, teams, and related business logic using a CQRS/Event Sourcing architecture.

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
1.  **Command:** A command is dispatched to represent an intent (e.g., `CreateUser`).
2.  **Aggregate:** The command is handled by an Aggregate, which validates the command and emits one or more events.
3.  **Event:** An event is persisted to the Event Store, representing a fact that has occurred (e.g., `UserCreated`).
4.  **Projector:** A Projector listens for events and updates a read model (a denormalized Ecto schema) in the database.
5.  **Projection (Read Model):** The updated Ecto schema that can be queried by the application.

**IMPORTANT:** When asked to add a feature that changes state, you MUST follow this CQRS/ES flow. Do not modify the database directly from a controller.

## 4. Development Workflow

### Initial Setup
1.  Copy the example config: `cp config/dev.local.example.exs config/dev.local.exs` (and fill in values)
2.  Install dependencies and set up the database: `mix setup`

### Running the Application
- Start the Phoenix server: `mix phx.server`
- Start with an interactive shell: `iex -S mix phx.server`

### Database Management
- Reset both EventStore and Ecto (dev): `mix reset.dev`
- Reset both databases (test): `mix reset.test`

### Testing
- Run all tests: `mix test`
- Run a single test file: `mix test test/path/to/file_test.exs`
- Run only tests affected by recent changes: `mix test --stale`

### Code Quality
- Format all code: `mix format`
- Run the linter: `mix credo`

## 5. Development Patterns

### Adding New Features (TDD is Mandatory)
1.  **Specification:** Create or update a spec file in the `/specs` directory.
2.  **Tests First:** Write tests before any implementation code.
3.  **CQRS Implementation:**
    -   Define **Commands** in `lib/reply_express/accounts/commands/`.
    -   Define **Events** in `lib/reply_express/accounts/events/`.
    -   Implement business logic in **Aggregates** in `lib/reply_express/accounts/aggregates/`.
    -   Update read models in **Projectors** in `lib/reply_express/accounts/projectors/`.
    -   Define read model schemas in **Projections** in `lib/reply_express/accounts/projections/`.
4.  **Controller:** Add the HTTP interface in `lib/reply_express_web/controllers/api/`.
5.  **Context:** Expose the functionality through the context module (e.g., `UsersContext`).

### Testing Patterns
-   **Aggregate Tests (`AggregateCase`):** Test command-to-event flow in isolation.
-   **Projector Tests (`DataCase`):** Test event-to-projection logic by calling the `handle/2` function directly with metadata.
-   **Controller Tests (`ConnCase`):** Test the full HTTP request/response cycle.
-   **Factories:** Use ExMachina factories from `test/support/factory.ex`.

**Projector Test Example:**
```elixir
# In a test using DataCase
event = %MyEvent{...}
:ok = MyProjector.handle(event, %{event_number: 1, handler_name: "my_handler"})

# Assert the projection was created/updated in the DB
assert Repo.get_by(MyProjection, ...)
```

### Type Specifications
All modules and functions must include `@type` and `@spec` definitions for clarity and static analysis.

## 6. API Design

- **Base Path:** `/api/v1/`
- **Authentication:** Session token-based.
- **Error Handling:** A central `FallbackController` handles errors and returns structured JSON responses (e.g., 422 for validation errors).

## 7. AI Assistant Workflow Rules

-   **Planning Phase:** When you say you want to create a plan, I will *only* create or edit a plan file in the `specs/` directory. I will not make any other changes to the codebase until you approve the plan.
-   **Implementation Phase:** When implementing a plan, I will work on one file at a time. After I have written the code for a file, I will verify with you before beginning work on the next file.
-   **TDD is mandatory.** Write tests *before* implementation. All new features require a spec in `/specs`.