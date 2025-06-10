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

  def user_projection_factory do
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

  def cmd_create_team_factory(attrs \\ %{}) do
    %CreateTeam{
      name: Map.get(attrs, :name, sequence("Test Team")),
      uuid: Map.get(attrs, :uuid, UUID.uuid4())
    }
  end

  def cmd_login_factory(attrs \\ %{}) do
    email = Map.get(attrs, :email, "test@email.local")
    password = Map.get(attrs, :password, "password")

    %Login{
      credentials: %{email: email, password: password},
      logged_in_at: Map.get(attrs, :logged_in_at, fn -> Timex.now() end).(),
      uuid: Map.get(attrs, :uuid, UUID.uuid4())
    }
  end

  def cmd_clear_user_tokens_factory(attrs \\ %{}) do
    %ClearUserTokens{
      uuid: Map.get(attrs, :uuid, UUID.uuid4())
    }
  end

  def cmd_generate_password_reset_token_factory(attrs \\ %{}) do
    %GeneratePasswordResetToken{
      email: Map.get(attrs, :email, "test@email.local"),
      token: Map.get(attrs, :token, nil),
      user_id: Map.get(attrs, :user_id, ""),
      user_uuid: Map.get(attrs, :user_uuid, ""),
      uuid: Map.get(attrs, :uuid, UUID.uuid4())
    }
  end

  def cmd_reset_password_factory(attrs \\ %{}) do
    password = Map.get(attrs, :password, "newpassword")

    %ResetPassword{
      password: password,
      password_confirmation: Map.get(attrs, :password_confirmation, password),
      token:
        Map.get(attrs, :token, fn -> :crypto.strong_rand_bytes(@rand_size) |> Base.encode64() end).(),
      uuid: Map.get(attrs, :uuid, UUID.uuid4()),
      hashed_password: Map.get(attrs, :hashed_password, "")
    }
  end

  def cmd_start_user_session_factory(attrs \\ %{}) do
    %StartUserSession{
      user_uuid: Map.get(attrs, :user_uuid, UUID.uuid4()),
      uuid: Map.get(attrs, :uuid, UUID.uuid4()),
      context: Map.get(attrs, :context, "session"),
      token: Map.get(attrs, :token, nil),
      logged_in_at: Map.get(attrs, :logged_in_at, nil),
      user_id: Map.get(attrs, :user_id, nil)
    }
  end
end
