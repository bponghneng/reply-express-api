---
trigger: always_on
---

# Code Style

## Style Guide
- Follow the [Elixir Style Guide](https://github.com/lexmag/elixir-style-guide).

## Ecto
- Prefer keyword-based queries over pipe-based queries
  - For example, use `User |> where(age: 18) |> select([u], u)` over `from(u in User, where: u.age > 18, select: u)`.

## Modules
- Use `alias` to shorten module names. For example, use `alias ReplyExpress.Accounts.Projections.User` instead of `ReplyExpress.Accounts.Projections.User`. 