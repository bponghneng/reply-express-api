---
trigger: always_on
---

# Testing & Debugging
- Run tests with `mix test --warnings-as-errors`. To be considered passing, tests must have no warnings or errors.
- After running any tests, check for linting errors with `mix credo --strict`.
- Prefer to assert on the result of a function call over matching on a pattern.
  - For example, assign the result of a function call to a variable and assert on the variable:
    ```elixir
    result = function_call()
    assert result == expected
    ```