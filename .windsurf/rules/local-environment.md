---
trigger: always_on
---

# Local Environment

## Reference Commands

### Essential Commands

This project uses [mise](https://mise.jdx.dev/) for managing Elixir and Erlang versions. To run Elixir or Erlang commands, prepend `mise exec --`, for example, `mise exec -- mix test` or `mise exec -- iex -S mix phx.server`.


```bash
# Testing
mix test                                      # Run all tests
mix test test/path/to/specific_test.exs       # Run specific test file
mix test --warnings-as-errors                 # Run with strict warning checking

# Code Quality
mix credo --strict                            # Run strict static code analysis
mix format                                    # Format code

# Database Management
mix reset.dev                                 # Reset both dev databases
mix reset.test                                # Reset both test databases

# Development Server
mix phx.server                                # Start Phoenix server
iex -S mix phx.server                         # Start with interactive shell
```

## Database Management

- **Reset Development Databases**:
    - Use `mix reset.dev` to reset both EventStore and Ecto databases.
    - Or individually:
        - `mix ecto.reset` for Ecto database only.
        - `mix eventstore.reset` for EventStore only.

- **Reset Test Databases**:
    - Use `mix reset.test` or:
        - `MIX_ENV=test mix ecto.reset`
        - `MIX_ENV=test mix eventstore.reset`