defmodule ReplyExpress.Accounts.UserTokensContextTest do
  @moduledoc """
  The Accounts context.
  """

  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.StartUserSession
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UserTokensContext
  alias ReplyExpress.Commanded

  import Ecto.Query, warn: false

  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "user_session_token_by_user_uuid/1" do
    test "returns UserTokenProjection when exists" do
      cmd_register = %RegisterUser{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        password: @valid_credentials.password,
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(cmd_register, consistency: :strong)

      %UserProjection{id: user_id} = Repo.one(UserProjection)

      cmd_login = %Login{
        credentials: @valid_credentials,
        id: user_id,
        logged_in_at: Timex.now(),
        uuid: cmd_register.uuid
      }

      :ok = Commanded.dispatch(cmd_login, consistency: :strong)

      cmd_start_user_session =
        %StartUserSession{
          context: "session",
          logged_in_at: cmd_login.logged_in_at,
          user_id: cmd_login.id,
          user_uuid: cmd_login.uuid,
          uuid: cmd_login.uuid
        }
        |> StartUserSession.build_session_token()

      :ok = Commanded.dispatch(cmd_start_user_session, consistency: :strong)

      %UserTokenProjection{context: result_context, user_uuid: user_uuid} =
        UserTokensContext.user_session_token_by_user_uuid(cmd_register.uuid)

      assert result_context == cmd_start_user_session.context
      assert user_uuid == cmd_register.uuid
    end
  end
end
