# Specification Template
> Ingest the information from this file, implement the Low-Level Tasks, and generate the code that will satisfy the High and Mid-Level Objectives.

## High-Level Objective

- Add a new context with supporting commands, events, and aggregates for creating a team.

## Mid-Level Objective

- Add a new context in `lib/reply_express/accounts/teams_context.ex`.
- Add a new command `ReplyExpress.Commands.CreateTeam` in `lib/reply_express/commands/create_team.ex`.
- Add a new function head for `execute/2` in `lib/reply_express/accounts/aggregates/team.ex`.
- Add a new event `ReplyExpress.Events.TeamCreated` in `lib/reply_express/events/team_created.ex`.

## Implementation Notes
- Use only the dependencies listed in `mix.exs`.
- Add @moduledoc to each module.
- Carefully review each low-level task for precise code changes.

## Context

### Beginning context
- `lib/reply_express_web/router.ex`
- `mix.exs` (readonly)
- `test/reply_express/accounts/users_context_test.exs` (readonly)

### Ending context
- `lib/reply_express/accounts/teams_context.ex` (new)
- `lib/reply_express/accounts/commands/create_team.ex` (new)
- `lib/reply_express/accounts/aggregates/team.ex` (new)
- `lib/reply_express/accounts/events/team_created.ex` (new)
- `lib/reply_express/accounts/projectors/team.ex` (new)
- `lib/reply_express/accounts/projectors/team_user.ex` (new)
- `lib/reply_express_web/controllers/api/v1/create_team_controller.ex` (new)
- `lib/reply_express_web/router.ex` (updated)
- `mix.exs` (readonly)
- `test/reply_express/accounts/users_context_test.exs` (readonly)

## Low-Level Tasks
> Ordered from start to finish

1. Create CreateTeam command.
```aider
CREATE `lib/reply_express/accounts/commands/create_team.ex`
  with properties for `name`, and `uuid`
  with validation rules for `name` including presence and for `uuid` including presence
  and stub the following functions:
    - set_name/1
    - set_uuid/1
```

2. CREATE TeamCreated event.
```aider
CREATE `lib/reply_express/accounts/events/team_created.ex`
  with defstruct properties for :name and :uuid
```

3. CREATE Team projector.
```aider
CREATE `lib/reply_express/accounts/projectors/team.ex`
  with project/2 function that projects the `TeamCreated` event
  using Multi.insert/3
```

4. CREATE Team aggregate.
```aider
CREATE `lib/reply_express/accounts/aggregates/team.ex`
  with function heads for:
    - execute/2 which returns a `TeamCreated` event
    - apply/2 which applies the `TeamCreated` event
```

5. CREATE teams_context_test.
```aider
CREATE `test/reply_express/accounts/teams_context_test.exs`
  with tests for:
    - create_team/1 that mirrors the tests of register_user/1 in `test/reply_express/accounts/users_context_test.exs`
    - team_by_uuid/1
```

6. CREATE teams_context.
```aider
CREATE `lib/reply_express/accounts/teams_context.ex`
  with function heads for:
    - create_team/1 that builds and dispatches a `CreateTeam` command
    - team_by_uuid/1 that returns a `TeamProjection` by `uuid`
```

7. CREATE teams_controller_test.
```aider
CREATE `test/reply_express_web/controllers/api/v1/teams_controller_test.exs`
  with tests for:
    - create/2
```

8. CREATE teams_controller.
```aider
CREATE `lib/reply_express_web/controllers/api/v1/teams_controller.ex`
  with function head for:
    - create/2
```

9. Add new endpoint to router for create team
```aider
UPDATE `lib/reply_express_web/router.ex`
  and add a new post endpoint for /api/vi/teams handled by `TeamsController.create/2`
```
