defmodule ReplyExpress.Factory do
  use ExMachina.Ecto, repo: ReplyExpress.Repo

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.Commands.RegisterUser

  @rand_size 32

  def register_user_factory do
    struct(RegisterUser, build(:user))
  end

  def user_factory do
    %{
      email: "test@email.local",
      password: "password1234",
      hashed_password: "4321drowssap"
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

  def user_token_projection_factory(attrs) do
    %UserTokenProjection{
      context: attrs.context,
      token: :crypto.strong_rand_bytes(@rand_size),
      user_id: attrs.user_id,
      user_uuid: attrs.user_uuid
    }
  end

  def set_user_projection_password(%UserProjection{} = user, password) do
    %{user | hashed_password: Pbkdf2.hash_pwd_salt(password)}
  end

  def set_user_password(user, password) do
    %{user | hashed_password: Pbkdf2.hash_pwd_salt(password)}
  end
end
