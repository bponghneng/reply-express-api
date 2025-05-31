defmodule ReplyExpress.Factory do
  use ExMachina.Ecto, repo: ReplyExpress.Repo

  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @rand_size 32

  def cmd_register_user_factory(attrs \\ %{}) do
    password = attrs["password"] || "password"

    %RegisterUser{
      email: "test@email.local",
      hashed_password: Pbkdf2.hash_pwd_salt(password),
      password: password,
      uuid: UUID.uuid4()
    }
  end

  def user_projection_factory() do
    %UserProjection{
      confirmed_at: nil,
      email: "test@email.local",
      hashed_password: Pbkdf2.hash_pwd_salt("password"),
      uuid: UUID.uuid4()
    }
  end

  def set_user_projection_password(%UserProjection{} = user_projection, password) do
    %UserProjection{user_projection | hashed_password: Pbkdf2.hash_pwd_salt(password)}
  end

  def user_token_projection_factory(attrs) do
    user = if Map.get(attrs, :user) != nil, do: attrs.user, else: nil
    sent_to = if user, do: user.email, else: Map.get(attrs, :sent_to)
    user_id = if user, do: user.id, else: Map.get(attrs, :user_id)
    user_uuid = if user, do: user.uuid, else: Map.get(attrs, :user_uuid)

    %UserTokenProjection{
      context: Map.get(attrs, :context) || "session",
      inserted_at: Map.get(attrs, :inserted_at) || Timex.now(),
      sent_to: sent_to,
      token: :crypto.strong_rand_bytes(@rand_size),
      uuid: UUID.uuid4(),
      user_id: user_id,
      user_uuid: user_uuid
    }
  end
end
