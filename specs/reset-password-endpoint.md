# New Endpoint for Change Password
> Ingest the information from this file, implement the Low-Level Tasks, and generate the code that will satisfy the High and Mid-Level Objectives.

## High-Level Objective

- Add a new endpoint and handler workflow for changing a user's password.

## Mid-Level Objective

- Add a new controller in `lib/reply_express_web/controllers/api/v1/reset_password_controller.ex`.
- Add a new endpoint in `lib/reply_express_web/router.ex`.
- Add a new function `reset_password/1` in `lib/reply_express/accounts/users_context.ex`.
- Add a new command `ReplyExpress.Commands.ResetPassword` in `lib/reply_express/commands/reset_password.ex`.
- Add a new function head for `execute/2` in `lib/reply_express/accounts/aggregates/user.ex`.
- Add a new event `ReplyExpress.Events.PasswordReset` in `lib/reply_express/events/password_reset.ex`.

## Implementation Notes

- Use only the dependencies listed in `mix.exs`.
- Add @moduledoc to each module.
- Carefully review each low-level task for precise code changes.

## Context

### Beginning context
- `lib/reply_express/accounts/aggregates/user.ex`
- `lib/reply_express/accounts/users_context.ex`
- `lib/reply_express/accounts/user_tokens_context.ex`
- `lib/reply_express/accounts/commands/generate_password_reset_token.ex` (readonly)
- `lib/reply_express/accounts/commands/register_user.ex` (readonly)
- `lib/reply_express/accounts/events/password_reset_token_generated.ex` (readonly)
- `lib/reply_express_web/controllers/api/v1/users/reset_password_controller.ex` (readonly)
- `lib/reply_express_web/router.ex`

### Ending context  
- `lib/reply_express_web/router.ex` (updated)
- `lib/reply_express_web/controllers/api/v1/reset_password_controller.ex` (new)
- `lib/reply_express/accounts/users_context.ex` (updated)
- `lib/reply_express/accounts/commands/reset_password.ex` (new)
- `lib/reply_express/accounts/aggregates/user.ex` (updated)
- `lib/reply_express/accounts/events/password_reset.ex` (new)

## Low-Level Tasks
> Ordered from start to finish

1. Stub ResetPasswordController
```aider
CREATE `lib/reply_express_web/controllers/api/v1/reset_password_controller.ex`
  that mimics the behavior of `lib/reply_express_web/controllers/api/v1/reset_password_controller.ex`
  and stub the function `create/2`
```
2. Add new endpoint to router for change password
```aider
UPDATE `lib/reply_express_web/router.ex`
  and add a new post endpoint for /api/vi/users/reset_password handled by `ResetPasswordController.create/2`
```
3. Stub reset_password/1 in users_context
```aider
UPDATE `lib/reply_express/accounts/users_context.ex`
  and stub the function `reset_password/1`
```
4. Create ResetPassword command
```aider
CREATE `lib/reply_express/accounts/commands/reset_password.ex`
  with properties for `hashed_password`, `password`, `password_confirmation`, `token`, `user_id` and `user_uuid`
  and stub the following functions:
    - hash_password/1 that mimics the behavior of `RegisterUser.hash_password/1`
    - set_user_properties/1 that mimics the behavior of `GeneratePasswordResetToken.set_user_properties/1`
```
5. Add function heads for execute/2 and apply/2 in user aggregate
```aider
UPDATE `lib/reply_express/accounts/aggregates/user.ex`
  and new function heads for:
    - execute(%User{token: token, uuid: user_uuid}, %ResetPassword{} = reset_password)
    - apply(%User{} = user, %PasswordReset{} = password_reset)
```
6. Create PasswordReset event
```aider
CREATE `lib/reply_express/accounts/events/password_reset.ex`
  that mimics the behavior of `lib/reply_express/accounts/events/password_reset_token_generated.ex`
  with properties for `hashed_password`, `password`, `password_confirmation`, `token`, `user_id` and `user_uuid`
```
