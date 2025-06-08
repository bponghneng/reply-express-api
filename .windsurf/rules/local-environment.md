---
trigger: always_on
---

# Local Environment
- When directed to reset the dev database, run `mix eventstore.reset` and `mix ecto.reset`.
- When directed to reset the test database, run `MIX_ENV=test mix eventstore.reset` and `MIX_ENV=test mix ecto.reset`.