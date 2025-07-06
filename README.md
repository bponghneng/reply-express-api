# ReplyExpress

A CQRS/Event Sourcing API built with Elixir and Phoenix that demonstrates modern enterprise architecture patterns for user authentication, team management, and scalable web services. This is the foundation for a lightweight customer support email messaging system.

## Background

[Corey Maass](https://github.com/corey-maass) had the initial idea for this product several years ago, and we briefly worked on it together. I rebooted it many months ago as a means to study CQRS and Event Sourcing. Recently, I have used it to study AI-assisted development. So now the goals are to build practical expertise in three key areas that are becoming increasingly important for staff engineers:

- **CQRS and Event Sourcing**: Modern architectural patterns for building scalable, maintainable systems with clear separation between command and query responsibilities
- **Elixir/Phoenix**: Functional programming and the Actor model for building fault-tolerant, concurrent applications  
- **AI-Assisted Development**: Leveraging AI tools like Claude Code and Aider for specification-driven development and automated code generation

When I rebooted it, I started out by implementing Phoenix Framework's built-in authentication system via CQRS and event sourcing using the Commanded library. At this stage, the authentication system is complete and working though I think there's still room for revision to make it more secure and to build in better DevX features.

## Streamlined Team Email Management Platform

ReplyExpress is a focused SaaS solution that transforms how small business teams handle shared email communications. Unlike heavyweight alternatives like Zendesk or Freshdesk, ReplyExpress delivers a lean, messaging-centric platform designed specifically for teams that need collaborative email management without enterprise complexity or cost.

### Core Value Proposition

The platform intercepts emails sent to shared addresses (support@, sales@, hello@) and creates a unified workspace where team members receive instant notifications and can collaboratively respond. Every email thread—including customer replies and internal team responses—is available in the user's inbox. Initially, replies are sent via a single-click-through web interface. In-email client replies are a key roadmap feature that will follow.

### Technical Architecture

Built on Elixir/Phoenix with CQRS and event sourcing patterns, ReplyExpress is designed for reliability and horizontal scaling from day one. The event-sourced architecture ensures complete audit trails and enables sophisticated features like conflict resolution and real-time collaboration. A key technical challenge being addressed is robust email threading across major email clients, particularly Gmail's complex conversation grouping.

### Flexible Use Cases

While perfect for customer support, the platform's messaging-first approach makes it equally valuable for sales inquiries, partnership communications, or any scenario where teams need to collaboratively manage incoming email volume.

### Development Roadmap

Currently implementing foundational team management and invitation systems, with core messaging functionality as the next milestone. Future enhancements include AI-powered sentiment analysis of incoming emails and intelligent reply suggestions using foundation model integration.

### Market Position

ReplyExpress targets the underserved small business market that finds traditional help desk solutions over-engineered and overpriced, offering essential collaborative email management without unnecessary feature bloat.

## Work-in-Progress

This version of the README represents the current state of an actively evolving project. My approach emphasizes specification-driven development with AI assistance, where each feature begins as a detailed markdown specification before any code is written.

### Current Architecture Status

The application currently implements a complete user authentication system with:
- User registration and login with secure password hashing (Pbkdf2)
- Session token management with automatic expiration
- Password reset workflows with secure token generation
- Team creation and management capabilities
- Comprehensive validation using Vex for business rules
- Full CQRS/Event Sourcing implementation with Commanded

**Key Implemented Features:**
- Registration endpoint (`POST /api/v1/users/register`)
- Login/logout session management (`POST/DELETE /api/v1/users/session`)  
- Password reset token generation (`POST /api/v1/users/reset_password_token`)
- Password reset execution (`POST /api/v1/users/reset_password`)
- Team creation (`POST /api/v1/teams`)
- Password change for authenticated users

### Development Approach

The project follows a strict specification-driven development process:

1. **Specification Creation**: Each feature starts with a detailed markdown spec in `/specs/` that defines high-level objectives, implementation notes, and step-by-step low-level tasks
2. **AI-Assisted Implementation**: Using tools like Aider and Claude Code to execute the specifications while maintaining code quality and architectural consistency
3. **Test-Driven Development**: Comprehensive test coverage using ExMachina factories and Phoenix ConnCase for HTTP endpoints
4. **Incremental Delivery**: Each feature is implemented as a complete vertical slice before moving to the next

### Testing Patterns

**Projector Testing with Commanded.Ecto.Projections:**

Projectors are tested by calling the `handle/2` method directly with proper metadata format:

```elixir
# Create test event
event = %UserAddedToTeam{
  team_uuid: team_uuid,
  user_uuid: user_uuid, 
  role: "member"
}

# Call projector with required metadata
:ok = TeamUserProjector.handle(event, %{
  event_number: 1,
  handler_name: "team_users"
})

# Verify projection was created
team_user = Repo.get_by(TeamUser, team_uuid: team_uuid, user_uuid: user_uuid)
assert team_user.role == "member"
```

**Key Requirements:**
- Use `DataCase` for database access
- Create prerequisite data via command dispatch (not direct inserts)
- Metadata must include `event_number` and `handler_name` keys
- Verify projections by querying the database directly

**Reference:** [Testing read model projectors - Commanded Recipes](https://github.com/commanded/recipes/issues/18)

### Architectural Decisions

**CQRS/Event Sourcing Implementation:**
- Events are the source of truth, stored in EventStore
- Projections provide optimized read models in PostgreSQL
- Commands represent intent and go through validation before execution
- Aggregates encapsulate business logic and emit events
- Projectors transform events into read-optimized data structures

**Code Organization:**
- Domain logic organized by bounded context (currently `accounts`)
- Clear separation between web layer (`lib/reply_express_web`) and domain layer (`lib/reply_express`)
- Comprehensive factory patterns for testing all command variations
- Centralized error handling via FallbackController

### Next Steps

The immediate roadmap focuses on expanding team management capabilities and introducing more complex business workflows that showcase advanced CQRS patterns. Future iterations will likely explore integration with external services (email, notifications) and more sophisticated authorization models.

Each development cycle involves creating specifications, implementing via AI assistance, and then documenting lessons learned about the intersection of traditional software engineering practices with AI-augmented development workflows.

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
  - `events`: Stores domain events and their definitions. Events capture facts about something that have happened within the domain, typically as a result of command execution.
  - `queries`: Contains query objects and handlers. Queries are used to retrieve data from the system without modifying state, supporting the "read" side of CQRS.
  - `projections`: Holds projection handlers and read models. Projections transform events into denormalized views or representations optimized for querying and display.
- API endpoint interface files are in `lib/reply_express_web`.

## Running the Application

To start your Phoenix server:

  * Copy `dev.local.example.exs` to `dev.local.exs` and fill in the values
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now API endpoints are available at `http://localhost:4000/api/v1`.
