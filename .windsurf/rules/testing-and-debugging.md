---
trigger: always_on
description: 
globs: 
---

# Testing & Debugging

Run tests using the flag `--warnings-as-errors`. To be considered passing, tests must have no warnings or errors.

## Asserting on Function Results

**Rule:** Prefer to assert on the result of a function call over matching on a pattern.

**Clarification:**

- Always assign the result of a function call to a variable first
- Then use assertions on that variable

**Examples:**

```elixir
# INCORRECT: Pattern matching on function call within assertion
assert {:ok, user} = Users.create_user(params)

# CORRECT: Store result, then assert on it
result = Users.create_user(params)

assert {:ok, user} = result
```

**Benefits:**

1. Makes test failures more explicit and clear
2. Shows what's being tested more obviously
3. Allows for more descriptive error messages
4. Easier to debug when tests fail
5. Follows the Arrange-Act-Assert pattern more clearly

**Additional Example:**

```elixir
# Testing a function with multiple assertions
test "user creation with valid data" do
  # Arrange
  valid_attrs = %{email: "test@example.com", password: "password123"}
  
  # Act
  {:ok, user} = Users.create_user(valid_attrs)
  
  # Assert
  assert user.email == valid_attrs.email
  assert is_binary(user.uuid)
end
```

## Testing Strategies

### Test Types and Patterns

- **Aggregate Tests**:
    - Use `AggregateCase` to test command → event flows in isolation.
    - Test both success and failure scenarios.
    - Example pattern:
      ```elixir
      # Test a successful command dispatch
      test "create user command emits user created event" do
        # Arrange
        uuid = UUID.uuid4()
        create_user = build(:cmd_create_user, uuid: uuid)
        
        # Act
        assert :ok = Commanded.dispatch(create_user)
        
        # Assert (using AggregateCase)
        assert_events create_user, [
          %UserCreated{uuid: uuid, email: create_user.email}
        ]
      end
      ```

- **Projector Tests**:
    - Use `DataCase` to test event → projection flows.
    - Test by calling `handle/2` directly with proper metadata.
    - Example pattern:
      ```elixir
      test "user created event creates user projection" do
        # Arrange
        uuid = UUID.uuid4()
        event = %UserCreated{uuid: uuid, email: "test@example.com"}
        
        # Act
        :ok = UserProjector.handle(event, %{
          event_number: 1,
          handler_name: "users"
        })
        
        # Assert
        user = Repo.get_by(UserProjection, uuid: uuid)
        assert user.email == "test@example.com"
      end
      ```

- **Controller Tests**:
    - Use `ConnCase` to test HTTP endpoints.
    - Test both success and error responses.
    - Verify proper status codes and response formats.
    - Example pattern:
      ```elixir
      test "create returns user when data is valid", %{conn: conn} do
        # Arrange
        user_params = %{
          "email" => "test@example.com",
          "password" => "password123"
        }
        
        # Act
        conn = post(conn, ~p"/api/v1/users", %{"user" => user_params})
        
        # Assert
        assert %{"data" => %{"uuid" => uuid, "email" => "test@example.com"}} = 
          json_response(conn, 201)
        assert Repo.get_by(UserProjection, uuid: uuid)
      end
      ```

- **Factory Usage**:
    - Use ExMachina factories from `test/support/factory.ex` for consistent test data.
    - Available command factories include:
        - `build(:cmd_register_user)`
        - `build(:cmd_create_team)`
        - `build(:cmd_login)`
        - etc.
    - Override defaults as needed: `build(:cmd_register_user, %{email: "custom@example.com"})`

## Debugging Techniques

- Run tests with `--trace` for detailed execution flow: `mix test --trace`
- Use `IEx.pry()` for interactive debugging (requires test to be run with `iex -S mix test`)
- Leverage telemetry for asynchronous event tracking in tests
- Run tests with `--warnings-as-errors` to catch potential issues early

## Reference Commands

```bash
# Testing
mix test                                      # Run all tests
mix test test/path/to/specific_test.exs       # Run specific test file
mix test --warnings-as-errors                 # Run with strict warning checking

# Code Quality
mix credo --strict                            # Run strict static code analysis
mix format                                    # Format code

# Database Management for Testing
mix reset.test                                # Reset both test databases
MIX_ENV=test mix ecto.reset                   # Reset only Ecto test database
MIX_ENV=test mix eventstore.reset             # Reset only EventStore test database
