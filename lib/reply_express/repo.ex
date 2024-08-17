defmodule ReplyExpress.Repo do
  use Ecto.Repo,
    otp_app: :reply_express,
    adapter: Ecto.Adapters.Postgres
end
