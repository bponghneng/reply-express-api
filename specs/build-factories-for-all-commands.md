# Test-Driven Development Plan for Command Factories

This document outlines a test-driven development (TDD) approach for implementing ExMachina factories for all command modules in the `lib/reply_express/accounts/commands` directory. Following ExMachina best practices, we'll enhance the existing factory module in `test/support/factory.ex` with factories for all command modules.

## Identified Commands

The following command modules have been identified in the `lib/reply_express/accounts/commands` directory:

1. `ClearUserTokens` - Command to clear user authentication tokens
2. `CreateTeam` - Command to create a new team
3. `GeneratePasswordResetToken` - Command to generate a password reset token
4. `Login` - Command to authenticate a user
5. `RegisterUser` (already implemented) - Command to register a new user
6. `ResetPassword` - Command to reset a user's password
7. `StartUserSession` - Command to start a new user session

## Implementation Steps

### Step 1: Analyze Command Modules

Before enhancing the factory, analyze all command modules to understand their structure:

1. Examine each command's fields, default values, and validation requirements
2. Document any special handling needed (like hashing passwords)
3. Note relationships between commands (if any)
4. Identify any fields keyed as `id` or containing `*_id` that should be excluded from factories

```bash
# List all command files to analyze
ls -la lib/reply_express/accounts/commands/*.ex
```

Ensure all command fields (except ID fields) are properly represented in the factory functions, with appropriate default values.

### Step 2: Update Factory Module

1. Following ExMachina best practices, we'll enhance the existing factory module in `test/support/factory.ex`
2. Update the module documentation and organization:

```elixir
# test/support/factory.ex
defmodule ReplyExpress.Factory do
  @moduledoc """
  Factory module for creating test data using ExMachina.
  """
  
  use ExMachina.Ecto, repo: ReplyExpress.Repo
  
  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  
  # Existing code...
end
```

3. Ensure module organization follows the Elixir Style Guide:
   - `@moduledoc` first
   - `use`, `import`, and `alias` statements
   - `@type` declarations
   - Module attributes (e.g., `@rand_size`)
   - `defstruct` (if applicable)
   - Function definitions

4. Run tests to verify the current implementation still works:

```bash
mix test --warnings-as-errors
```

5. Check for linting errors:

```bash
mix credo --strict
```

### Step 3: TDD Implementation Approach

For each command factory, we will follow these TDD steps:

1. Write a test that expects the factory to produce a command with expected default values
2. Run the test to verify it fails (as the factory doesn't exist yet)
3. Implement the factory in `test/support/factory.ex` following ExMachina best practices:
   - Use `sequence/2` for generating unique values where appropriate
   - Use anonymous functions for dynamic values (timestamps, random tokens)
   - Exclude any fields keyed as `id` or containing `*_id`
   - Use `Map.get/3` for accessing map values with defaults
4. Run the test again to ensure it passes without warnings
5. Refactor if necessary

### Step 4: Create the Factory Test File

Create a dedicated test file for testing the factories:

```elixir
# test/reply_express/factory_test.exs
defmodule ReplyExpress.FactoryTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ReplyExpress.DataCase
  import ReplyExpress.Factory

  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Commands.StartUserSession
end
```

Note that we're placing this test in the proper `test/reply_express/` directory structure to match our module organization, and we're using both `ExUnit.Case` with `async: true` for better test performance and `ReplyExpress.DataCase` for database access.

### Step 5: Implement Tests for Each Factory

We'll implement a test for each command factory, following the project's testing guideline to assert on results rather than pattern matching:

#### RegisterUser Test (Already Implemented)

```elixir
# test/reply_express/factory_test.exs
test "cmd_register_user_factory/0 builds a valid RegisterUser command" do
  result = build(:cmd_register_user)
  
  assert %RegisterUser{} = result
  assert result.email == "test@email.local"
  assert result.password == "password"
  assert is_binary(result.hashed_password)
  assert is_binary(result.uuid)
end

test "cmd_register_user_factory/1 overrides default values" do
  result = build(:cmd_register_user, %{"password" => "custom_password"})
  
  assert result.password == "custom_password"
end
```

#### CreateTeam Test

```elixir
test "cmd_create_team_factory/0 builds a valid CreateTeam command" do
  result = build(:cmd_create_team)
  
  assert %CreateTeam{} = result
  assert String.starts_with?(result.name, "Test Team")
  assert is_binary(result.uuid)
end

test "cmd_create_team_factory/1 overrides default values" do
  result = build(:cmd_create_team, name: "Custom Team")
  
  assert result.name == "Custom Team"
end
```

#### Login Test

```elixir
test "cmd_login_factory/0 builds a valid Login command" do
  result = build(:cmd_login)
  
  assert %Login{} = result
  assert result.credentials.email == "test@email.local"
  assert result.credentials.password == "password"
  assert %DateTime{} = result.logged_in_at
end

test "cmd_login_factory/1 overrides default values" do
  result = build(:cmd_login, email: "custom@email.com", password: "custom_pass")
  
  assert result.credentials.email == "custom@email.com"
  assert result.credentials.password == "custom_pass"
end
```

#### ClearUserTokens Test

```elixir
test "cmd_clear_user_tokens_factory/0 builds a valid ClearUserTokens command" do
  result = build(:cmd_clear_user_tokens)
  
  assert %ClearUserTokens{} = result
  assert result.context == "session"
  assert is_binary(result.user_uuid)
end

test "cmd_clear_user_tokens_factory/1 overrides default values" do
  result = build(:cmd_clear_user_tokens, context: "reset")
  
  assert result.context == "reset"
end
```

#### GeneratePasswordResetToken Test

```elixir
test "cmd_generate_password_reset_token_factory/0 builds a valid GeneratePasswordResetToken command" do
  result = build(:cmd_generate_password_reset_token)
  
  assert %GeneratePasswordResetToken{} = result
  assert result.email == "test@email.local"
  assert is_binary(result.uuid)
  assert is_nil(result.token)
  # Ensure no user_id field is present
  refute Map.has_key?(result, :user_id)
end

test "cmd_generate_password_reset_token_factory/1 overrides default values" do
  result = build(:cmd_generate_password_reset_token, email: "custom@email.com")
  
  assert result.email == "custom@email.com"
end
```

#### ResetPassword Test

```elixir
test "cmd_reset_password_factory/0 builds a valid ResetPassword command" do
  result = build(:cmd_reset_password)
  
  assert %ResetPassword{} = result
  assert result.password == "newpassword"
  assert result.password_confirmation == "newpassword"
  assert is_binary(result.token)
  assert is_binary(result.uuid)
end

test "cmd_reset_password_factory/1 overrides default values" do
  result = build(:cmd_reset_password, password: "custom", password_confirmation: "custom")
  
  assert result.password == "custom"
  assert result.password_confirmation == "custom"
end
```

#### StartUserSession Test

```elixir
test "cmd_start_user_session_factory/0 builds a valid StartUserSession command" do
  result = build(:cmd_start_user_session)
  
  assert %StartUserSession{} = result
  assert is_binary(result.user_uuid)
  assert is_binary(result.uuid)
end

test "cmd_start_user_session_factory/1 overrides default values" do
  uuid = UUID.uuid4()
  result = build(:cmd_start_user_session, user_uuid: uuid)
  
  assert result.user_uuid == uuid
end
```

### Step 6: Run Tests and Watch Them Fail

Run the tests with:

```bash
mix test test/reply_express/factory_test.exs --warnings-as-errors
```

We expect the tests for the new factories to fail since we haven't implemented them yet.

### Step 7: Implement Factories

#### Update Module Aliases in Factory Module

```elixir
# test/support/factory.ex
defmodule ReplyExpress.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: ReplyExpress.Repo

  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  # ... existing code
end
```

#### Implement Each Factory Function

##### CreateTeam Factory

```elixir
def cmd_create_team_factory(attrs \\ %{}) do
  %CreateTeam{
    name: Map.get(attrs, :name, sequence("Test Team")),
    uuid: Map.get(attrs, :uuid, UUID.uuid4())
  }
end
```

##### Login Factory

```elixir
def cmd_login_factory(attrs \\ %{}) do
  email = Map.get(attrs, :email, "test@email.local")
  password = Map.get(attrs, :password, "password")
  
  %Login{
    credentials: %{email: email, password: password},
    logged_in_at: Map.get(attrs, :logged_in_at, fn -> Timex.now() end),
    uuid: Map.get(attrs, :uuid, UUID.uuid4())
  }
end
```

##### ClearUserTokens Factory

```elixir
def cmd_clear_user_tokens_factory(attrs \\ %{}) do
  %ClearUserTokens{
    user_uuid: Map.get(attrs, :user_uuid, UUID.uuid4()),
    context: Map.get(attrs, :context, "session")
  }
end
```

##### GeneratePasswordResetToken Factory

```elixir
def cmd_generate_password_reset_token_factory(attrs \\ %{}) do
  %GeneratePasswordResetToken{
    email: Map.get(attrs, :email, "test@email.local"),
    # Exclude user_id as per best practices
    token: Map.get(attrs, :token, nil),
    uuid: Map.get(attrs, :uuid, UUID.uuid4())
  }
end
```

##### ResetPassword Factory

```elixir
def cmd_reset_password_factory(attrs \\ %{}) do
  password = Map.get(attrs, :password, "newpassword")
  
  %ResetPassword{
    password: password,
    password_confirmation: Map.get(attrs, :password_confirmation, password),
    token: Map.get(attrs, :token, fn -> :crypto.strong_rand_bytes(32) end),
    uuid: Map.get(attrs, :uuid, UUID.uuid4())
  }
end
```

##### StartUserSession Factory

```elixir
def cmd_start_user_session_factory(attrs \\ %{}) do
  %StartUserSession{
    user_uuid: Map.get(attrs, :user_uuid, UUID.uuid4()),
    uuid: Map.get(attrs, :uuid, UUID.uuid4())
  }
end
```

### Step 8: Run Tests Again

Run the tests to ensure they pass:

```bash
# First run the specific factory tests
mix test test/reply_express/factory_test.exs --warnings-as-errors

# Then run the full test suite to verify everything works together
mix test --warnings-as-errors
```

### Step 9: Check for Linting Errors

```bash
mix credo --strict
```

Fix any linting errors that might appear.

### Implementation Order Summary

1. Analyze all command modules to understand their structure and requirements
   - Identify all fields in each command
   - Note any ID fields that should be excluded from factories
   - Identify fields that should use sequence or dynamic values
2. Keep factory.ex in test/support directory as per ExMachina best practices
   - Properly organize module according to Elixir Style Guide
   - Ensure documentation is appropriate
3. Update the factory module with proper aliases and organization
4. Create test file with tests for all factories
   - Follow asserting on results pattern instead of pattern matching
   - Structure tests with proper describes and contexts
5. Run tests to verify failure (red phase of TDD)
6. Implement each factory one by one, following these best practices:
   - Use sequence/2 for unique fields like team names
   - Use anonymous functions for dynamic values (timestamps, tokens)
   - Exclude any fields keyed as `id` or containing `*_id`
   - Use `Map.get/3` for accessing map values with defaults
7. Run tests after each implementation to verify correctness (green phase)
8. Refactor if necessary while keeping tests passing (refactor phase)
9. Run full test suite with --warnings-as-errors to ensure no warnings
10. Run credo with --strict to check for linting issues
11. Consider splitting factories into separate modules if they grow too large

### Style Guidelines

All implementations will follow:

1. The [Elixir Style Guide](https://github.com/lexmag/elixir-style-guide) as referenced in the project's code style guide

2. Module organization:
   ```elixir
   defmodule ModuleName do
     @moduledoc "..."
     
     use ...
     import ...
     alias ...
     
     @type ...
     
     @module_attribute ...
     
     defstruct [...]
     
     # functions
   end
   ```

3. Test practices:
   - Assign the result of a function call to a variable and assert on the variable
   - Example:
     ```elixir
     # Good
     result = build(:cmd_register_user)
     assert result.email == "test@email.local"
     
     # Avoid
     assert %{email: "test@email.local"} = build(:cmd_register_user)
     ```

4. Factory function naming convention:
   - Prefix with `cmd_` for command factories
   - Use snake_case for the rest of the name
   - End with `_factory`
   - Example: `cmd_register_user_factory`

5. ExMachina best practices:
   - Use `sequence/2` for unique attributes (e.g., `sequence("Test Team")`)
   - Use anonymous functions for delayed evaluation of dynamic attributes:
     ```elixir
     # Good - evaluated when the struct is built
     logged_in_at: Map.get(attrs, :logged_in_at, fn -> Timex.now() end)
     
     # Avoid - evaluated when the module is compiled
     logged_in_at: Map.get(attrs, :logged_in_at, Timex.now())
     ```
   - Exclude ID fields from factories
   - Use `Map.get/3` for attribute defaults
