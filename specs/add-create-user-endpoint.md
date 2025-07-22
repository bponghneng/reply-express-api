# Add Create User API Endpoint Specification

## Overview
This specification outlines the implementation of a new POST API endpoint for creating users. The endpoint will leverage the existing `CreateUser` command and follow established patterns in the codebase.

## API Endpoint Design

### Route
- **Method**: POST
- **Path**: `/api/v1/users`
- **Controller**: `ReplyExpressWeb.API.V1.Users.UserController`
- **Action**: `create`

### Request Format
```json
{
  "user": {
    "email": "user@example.com",
    "password": "securepassword123"
  }
}
```

### Response Format
**Success (201 Created):**
```json
{
  "data": {
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "confirmed_at": null,
    "inserted_at": "2025-07-21T21:01:10",
    "updated_at": "2025-07-21T21:01:10"
  }
}
```

**Error (422 Unprocessable Entity):**
```json
{
  "errors": {
    "user": ["is required"]
  }
}
```

Or for validation errors:
```json
{
  "errors": {
    "email": ["can't be empty"],
    "password": ["can't be empty"]
  }
}
```

## Implementation Plan

### 1. Router Changes
**File**: `lib/reply_express_web/router.ex`

Add the new route within the existing users scope:
```elixir
scope path: "/users", alias: Users do
  # Existing routes...
  post "/", UserController, :create  # New route
end
```

### 2. New Controller
**File**: `lib/reply_express_web/controllers/api/v1/users/user_controller.ex`

Create a new controller following the existing pattern:
- Use `ReplyExpressWeb, :controller`
- Import necessary aliases (`UsersContext`, `UserProjection`)
- Set `action_fallback ReplyExpressWeb.API.V1.FallbackController`
- Implement `create/2` function with proper parameter validation
- Handle both success and error cases

Key features:
- Validate presence of "user" parameter
- Call `UsersContext.create_user/1`
- Return appropriate HTTP status codes
- Follow existing error handling patterns

### 3. JSON View Module
**File**: `lib/reply_express_web/controllers/api/v1/users/user_json.ex`

Refactor the existing RegistrationJSON module:
- Rename `RegistrationJSON` to `UserJSON` to make it more generic
- Move the file from `registration_json.ex` to `user_json.ex`
- Update the module documentation to reflect its generic purpose
- Keep the same rendering logic to maintain identical response formats
- Update all references to RegistrationJSON in other files (e.g., RegistrationController)

Implementation details:
- The module will contain the same `show/1` function to render a single user
- Same data fields will be included: uuid, email, confirmed_at, inserted_at, updated_at
- Module should be used by both registration and user creation endpoints

### 4. UsersContext Changes
**File**: `lib/reply_express/accounts/users_context.ex`

Add new `create_user/1` function:
- Accept user parameters (email, password)
- Generate UUID for new user
- Hash the password using existing password hashing utilities
- Build and dispatch `CreateUser` command
- Handle command dispatch results
- Return `{:ok, user_projection}` or `{:error, reason}`

Implementation details:
- Use `UUID.uuid4()` for user UUID generation
- Use `Bcrypt.hash_pwd_salt/1` for password hashing
- Leverage existing `CreateUser` command structure
- Follow consistency patterns used in other context functions
- Query for user projection after successful command dispatch

### 5. Existing Command Usage
**File**: `lib/reply_express/accounts/commands/create_user.ex`

The existing `CreateUser` command will be used as-is. It already provides:
- Proper struct definition with required fields
- Validation for uuid, email, and hashed_password
- Helper functions for setting command properties

## Key Differences from Registration

This create user endpoint differs from the existing registration endpoint:
- **Registration**: Creates user + triggers team creation workflow
- **Create User**: Creates user only, without additional workflows
- **Use Case**: Administrative user creation or simplified user creation scenarios

## Implementation Task List

Following a strict TDD workflow, these tasks will be implemented in sequence:

1. **Write test for create_user/1 in UsersContext**
   - Test creating a user with valid data
   - Test validation for unique email
   - Test validation for password requirements
   - Run tests to confirm they fail properly

2. **Add create_user/1 to UsersContext**
   - Implement function with UUID generation
   - Add password hashing
   - Build and dispatch CreateUser command
   - Handle command dispatch results
   - Verify command and projection usage
   - Run tests to confirm implementation works

3. **Refactor RegistrationJSON to UserJSON**
   - Rename file from registration_json.ex to user_json.ex
   - Update module name to UserJSON
   - Update module documentation
   - Update references in RegistrationController
   - Run tests to confirm refactoring works

4. **Add POST /api/v1/users route to router.ex**
   - Add route within existing users scope
   - Run tests to confirm routing works

5. **Create UserController with create/2 action**
   - Implement controller following existing patterns
   - Add proper error handling
   - Note: parameter validation happens in command
   - Run tests to confirm controller works

6. **Write comprehensive tests for endpoint**
   - Test success case with valid parameters
   - Test error handling for invalid/missing parameters
   - Test password hashing
   - Verify response format matches specification
   - Ensure request and response match registration endpoint

Each task will be completed and verified before moving to the next task.

## Error Handling

The endpoint will handle various error scenarios:
- Missing or empty "user" parameter → 422 with validation error
- Invalid email format → 422 with validation error
- Command dispatch failures → Handled by FallbackController
- Database/projection errors → Handled by FallbackController

## Security Considerations

- Password will be hashed before storage using Bcrypt
- No sensitive data (passwords, tokens) in API responses
- Follow existing authentication patterns if needed in future
- Validate email format and uniqueness through existing validations

## Testing Strategy

Tests should cover:
- Successful user creation with valid parameters
- Error handling for missing/invalid parameters
- Password hashing verification
- JSON response format validation
- Integration with existing command/event system

## Dependencies

This implementation leverages existing codebase components:
- `ReplyExpress.Accounts.Commands.CreateUser` (existing)
- `ReplyExpress.Accounts.Projections.User` (existing)
- `ReplyExpress.Commanded` (existing)
- Phoenix controller and JSON view patterns (existing)
- Bcrypt for password hashing (existing)
- UUID generation utilities (existing)
