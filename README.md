# ReplyExpress

## Project Structure

- This project uses the Elixir programming language and the Phoenix Framework web framework. It relies on the following external dependencies:
  - [Commanded](https://hexdocs.pm/commanded/) for event sourcing and command handling.
  - [Ecto](https://hexdocs.pm/ecto/) for database interactions.
  - [Pbkdf2](https://hexdocs.pm/pbkdf2_elixir/) for password hashing.
  - [Timex](https://hexdocs.pm/timex/) for date and time handling.
  - [UUID](https://hexdocs.pm/uuid/) for generating unique identifiers.
- The main application logic is in `lib/reply_express`.
- Directories in `lib/reply_express` are grouped by domain. Each domain contains subdirectories for command query responsibility segregation (CQRS) and event sourcing elements:
  - `aggregates`: Contains aggregate roots, which encapsulate domain entities and business logic. Aggregates enforce invariants and are the primary entry point for handling commands within the domain.
  - `commands`: Defines command data structures and handlers. Commands represent requests to perform actions that change state in the system.
  - `events`: Stores domain events and their definitions. Events capture facts about something that has happened within the domain, typically as a result of command execution.
  - `queries`: Contains query objects and handlers. Queries are used to retrieve data from the system without modifying state, supporting the "read" side of CQRS.
  - `projections`: Holds projection handlers and read models. Projections transform events into denormalized views or representations optimized for querying and display.
- API endpoint interface files are in `lib/reply_express_web`.

## Running the Application

To start your Phoenix server:

  * Copy `dev.local.example.exs` to `dev.local.exs` and fill in the values
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
