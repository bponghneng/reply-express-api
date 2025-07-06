defmodule ReplyExpress.Accounts.UsersContext.Test do
  @moduledoc false

  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Commands.GeneratePasswordResetToken
  alias ReplyExpress.Accounts.Commands.RegisterUser
  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UsersContext
  alias ReplyExpress.Commanded
  alias ReplyExpress.Repo

  @valid_credentials %{email: "test@email.local", password: "password1234"}
  @valid_user_attrs %{email: "test@email.local", password: "password1234"}

  describe "login" do
    setup do
      # GenServer.start_link(UserTokenProjection, [], application: ReplyExpress.Commanded, name: :user_tokens)
      command = %RegisterUser{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        password: @valid_credentials.password,
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(command, consistency: :strong)

      %{command: command}
    end

    test "logs in, creates session token", %{command: command} do
      {:ok, token} = UsersContext.login(%{"credentials" => @valid_credentials})

      assert %UserTokenProjection{} = token
      assert token.context == "session"
      assert token.user_uuid == command.uuid
    end

    test "resets session token when valid one exists" do
      # Create initial session token
      {:ok, %UserTokenProjection{} = initial_token} =
        UsersContext.login(%{"credentials" => @valid_credentials})

      # Log in again to reset token
      {:ok, %UserTokenProjection{} = result_token} =
        UsersContext.login(%{"credentials" => @valid_credentials})

      assert UserTokenProjection |> Repo.all() |> length() == 1
      assert result_token.context == "session"
      refute result_token.token == initial_token.token
    end
  end

  describe "generate_password_reset_token/1" do
    test "Creates token and sends email with password reset link" do
      # Register user using the register_user function which ensures the projection is created
      {:ok, user} =
        UsersContext.register_user(%{
          email: @valid_credentials.email,
          password: @valid_credentials.password
        })

      # Generate the password reset token
      {:ok, %UserTokenProjection{} = user_token} =
        UsersContext.generate_password_reset_token(%{email: @valid_credentials.email})

      assert user_token.user_uuid == user.uuid
      assert user_token.context == "reset_password"
    end
  end

  describe "register_user/1" do
    test "Registers new user from valid data" do
      {:ok, %UserProjection{} = user} = UsersContext.register_user(@valid_user_attrs)

      assert user.email == @valid_user_attrs.email
    end

    test "Validates email is unique" do
      UsersContext.register_user(@valid_user_attrs)

      # Email address already registered
      {:error, :validation_failure, errors} = UsersContext.register_user(@valid_user_attrs)

      assert errors == %{email: ["has already been taken"]}
    end

    test "Validates password is at least 8 characters" do
      {:error, :validation_failure, errors} =
        UsersContext.register_user(%{@valid_user_attrs | password: "invalid"})

      # Extract message from parameterized error
      assert errors
             |> Map.get(:password)
             |> Enum.at(0)
             |> Keyword.get(:message) == "must be at least 8 characters"
    end
  end

  describe "reset_password/1" do
    setup do
      cmd_register = %RegisterUser{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        password: @valid_credentials.password,
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(cmd_register, consistency: :strong)

      cmd_reset =
        GeneratePasswordResetToken.new(%{email: @valid_credentials.email})
        |> GeneratePasswordResetToken.assign_uuid(UUID.uuid4())
        |> GeneratePasswordResetToken.build_reset_password_token()
        |> GeneratePasswordResetToken.set_user_properties()

      :ok = Commanded.dispatch(cmd_reset, consistency: :strong)

      user_token = Repo.one(UserTokenProjection)

      %{
        cmd_reset: cmd_reset,
        cmd_register: cmd_register,
        user_token: user_token
      }
    end

    test "Updates a user's password", %{user_token: user_token} do
      {:ok, %ResetPassword{} = token} =
        UsersContext.reset_password(%{
          password: @valid_user_attrs.password,
          password_confirmation: @valid_user_attrs.password,
          token: Base.encode64(user_token.token)
        })

      assert token.password == @valid_user_attrs.password
      assert token.password_confirmation == @valid_user_attrs.password
      assert token.token == Base.encode64(user_token.token)
      assert token.uuid == user_token.user_uuid
    end

    test "Validates required fields" do
      {:error, :validation_failure, errors} = UsersContext.reset_password(%{})

      assert errors.password == ["can't be empty"]
      assert errors.token == ["can't be empty"]
    end

    test "Validates password_confirmation", %{user_token: user_token} do
      {:error, :validation_failure, errors} =
        UsersContext.reset_password(%{
          password: @valid_user_attrs.password,
          password_confirmation: "does not match",
          token: Base.encode64(user_token.token)
        })

      assert errors.password == ["passwords do not match"]
    end

    test "Deletes all of a user's existing tokens", %{user_token: user_token} do
      UsersContext.reset_password(%{
        password: @valid_user_attrs.password,
        password_confirmation: @valid_user_attrs.password,
        token: Base.encode64(user_token.token)
      })

      token = Repo.all(UserTokenProjection)

      assert token == []
    end
  end
end
