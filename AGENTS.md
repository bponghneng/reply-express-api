## AGENTS.md

This guide is for AI agents working in this Elixir/Phoenix CQRS codebase.

### Essential Commands

- **Run all tests:** `mix test`
- **Run a single test file:** `mix test test/path/to/specific_test.exs`
- **Run static code analysis:** `mix credo`
- **Format code:** `mix format`
- **Reset dev databases:** `mix reset.dev`

### Code Style & Patterns

- **TDD is mandatory.** Write tests *before* implementation. All new features require a spec in `/specs`.
- **CQRS/Event Sourcing:** Follow the established pattern:
    1.  **Commands:** `lib/reply_express/accounts/commands/`
    2.  **Events:** `lib/reply_express/accounts/events/`
    3.  **Aggregates:** `lib/reply_express/accounts/aggregates/` (business logic)
    4.  **Projectors:** `lib/reply_express/accounts/projectors/` (update read models)
- **Typespecs:** All modules and functions must have `@type` and `@spec` definitions.
- **Validation:** Use `Vex` for command validation.
- **Error Handling:** Centralized in `FallbackController`. Validation errors return 422.
- **Factories:** Use ExMachina factories from `test/support/factory.ex` for tests. See `CLAUDE.md` for available factories.
