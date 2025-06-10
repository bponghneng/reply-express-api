defmodule ReplyExpress.FactoryTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use ReplyExpress.DataCase

  import ReplyExpress.Factory

  alias ReplyExpress.Accounts.Commands.ClearUserTokens
  alias ReplyExpress.Accounts.Commands.CreateTeam
  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Commands.StartUserSession

  describe "cmd_register_user_factory/1" do
    test "builds a valid RegisterUser command" do
      result = build(:cmd_register_user)

      assert %RegisterUser{} = result
      assert result.email == "test@email.local"
      assert result.password == "password"
      assert is_binary(result.hashed_password)
      assert is_binary(result.uuid)
    end

    test "overrides default values" do
      result = build(:cmd_register_user, %{"password" => "custom_password"})

      assert result.password == "custom_password"
    end
  end

  describe "cmd_create_team_factory/1" do
    test "builds a valid CreateTeam command" do
      result = build(:cmd_create_team)

      assert %CreateTeam{} = result
      assert String.starts_with?(result.name, "Test Team")
      assert is_binary(result.uuid)
    end

    test "overrides default values" do
      result = build(:cmd_create_team, name: "Custom Team")

      assert result.name == "Custom Team"
    end
  end

  describe "cmd_login_factory/1" do
    test "builds a valid Login command" do
      result = build(:cmd_login)

      assert %Login{} = result
      assert result.credentials.email == "test@email.local"
      assert result.credentials.password == "password"
      assert %DateTime{} = result.logged_in_at
    end

    test "overrides default values" do
      result = build(:cmd_login, email: "custom@email.com", password: "custom_pass")

      assert result.credentials.email == "custom@email.com"
      assert result.credentials.password == "custom_pass"
    end
  end

  describe "cmd_clear_user_tokens_factory/1" do
    test "builds a valid ClearUserTokens command" do
      result = build(:cmd_clear_user_tokens)

      assert %ClearUserTokens{} = result
      assert is_binary(result.uuid)
    end

    test "overrides default values" do
      uuid = UUID.uuid4()
      result = build(:cmd_clear_user_tokens, uuid: uuid)

      assert result.uuid == uuid
    end
  end

  describe "cmd_generate_password_reset_token_factory/1" do
    test "builds a valid GeneratePasswordResetToken command" do
      result = build(:cmd_generate_password_reset_token)

      assert %GeneratePasswordResetToken{} = result
      assert result.email == "test@email.local"
      assert is_binary(result.uuid)
      assert is_nil(result.token)
      # Ensure no user_id field is excluded from factory as per best practices
      assert result.user_id == ""
      assert result.user_uuid == ""
    end

    test "overrides default values" do
      result = build(:cmd_generate_password_reset_token, email: "custom@email.com")

      assert result.email == "custom@email.com"
    end
  end

  describe "cmd_reset_password_factory/1" do
    test "builds a valid ResetPassword command" do
      result = build(:cmd_reset_password)

      assert %ResetPassword{} = result
      assert result.password == "newpassword"
      assert result.password_confirmation == "newpassword"
      assert is_binary(result.token)
      assert is_binary(result.uuid)
    end

    test "overrides default values" do
      result = build(:cmd_reset_password, password: "custom", password_confirmation: "custom")

      assert result.password == "custom"
      assert result.password_confirmation == "custom"
    end
  end

  describe "cmd_start_user_session_factory/1" do
    test "builds a valid StartUserSession command" do
      result = build(:cmd_start_user_session)

      assert %StartUserSession{} = result
      assert is_binary(result.user_uuid)
      assert is_binary(result.uuid)
      assert result.context == "session"
    end

    test "overrides default values" do
      uuid = UUID.uuid4()
      result = build(:cmd_start_user_session, user_uuid: uuid)

      assert result.user_uuid == uuid
    end
  end
end
