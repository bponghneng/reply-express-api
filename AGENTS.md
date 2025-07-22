## AGENTS.md

This guide is for AI agents working in this Elixir/Phoenix CQRS codebase.

### Essential Commands

- **Run all tests:** `mix test`
- **Run a single test file:** `mix test test/path/to/specific_test.exs`
- **Run static code analysis:** `mix credo`
- **Format code:** `mix format`
- **Reset dev databases:** `mix reset.dev`

### Code Style & Patterns

### Workflow Rules

- **Planning Phase:** When you say you want to create a plan, I will *only* create or edit a plan file in the `specs/`
  directory. I will not make any other changes to the codebase until you approve the plan.
- **Implementation Phase:** When implementing a plan, I will work on one file at a time. After I have written the code
  for a file, I will verify with you before beginning work on the next file.
- **TDD is mandatory.** Write tests *before* implementation. All new features require a spec in `/specs`.
- **CQRS/Event Sourcing:** Follow the established pattern:
    1. **Commands:** `lib/reply_express/accounts/commands/`
    2. **Events:** `lib/reply_express/accounts/events/`
    3. **Aggregates:** `lib/reply_express/accounts/aggregates/` (business logic)
    4. **Projectors:** `lib/reply_express/accounts/projectors/` (update read models)
- **Typespecs:** Modules and functions should have `@type` and `@spec` definitions where appropriate.
- **Validation:** Use `Vex` for command validation.
- **Error Handling:** Centralized in `FallbackController`. Validation errors return 422.
- **Factories:** Use ExMachina factories from `test/support/factory.ex` for tests. See `CLAUDE.md` for available
  factories.
