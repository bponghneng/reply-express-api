---
trigger: always_on
description: 
globs: 
---

# Code Style

## Style Guide
- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide).

## Ecto
- Prefer keyword-based queries over pipe-based queries
  - For example, use `User |> where(age: 18) |> select([u], u)` over `from(u in User, where: u.age > 18, select: u)`.

## Modules
- Following the `defmodule` statement, organize module elements as follows:
  - `@moduledoc`, then `use`, `import`, `alias` and `require`
  - `@type` statements
  - Module attributes, e.g., `@valid_credentials`
  - `defstruct` statement
  - All other elements
- Use `alias` to shorten module names. For example, use `alias ReplyExpress.Accounts.Projections.User` instead of `ReplyExpress.Accounts.Projections.User`.