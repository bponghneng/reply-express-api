defmodule ReplyExpress.Accounts.UsersContext.Test do
  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Commands.ResetPassword
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UsersContext

  @valid_user_attrs %{email: "test@email.local", password: "password1234"}

  describe "generate_password_reset_token/1" do
    test "Creates token and sends email with password reset link" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      {:ok, %UserTokenProjection{} = user_token} =
        UsersContext.generate_password_reset_token(%{email: @valid_user_attrs.email})

      assert user_token.user_uuid == user_projection.uuid
      assert user_token.context == "reset_password"
    end
  end

  describe "log_in_user/1" do
    test "Logs in a registered user from valid email and password" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      {:ok, %UserTokenProjection{} = user_token} =
        UsersContext.log_in_user(%{credentials: @valid_user_attrs})

      assert user_token.user_uuid == user_projection.uuid
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
    test "Updates a user's password" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      user_token_projection =
        :user_token_projection
        |> build(context: "reset_password", user: user_projection)
        |> insert()

      {:ok, %ResetPassword{} = result} =
        UsersContext.reset_password(%{
          password: @valid_user_attrs.password,
          password_confirmation: @valid_user_attrs.password,
          token: Base.encode64(user_token_projection.token)
        })

      assert result.password == @valid_user_attrs.password
      assert result.password_confirmation == @valid_user_attrs.password
      assert result.token == Base.encode64(user_token_projection.token)
      assert result.uuid == user_projection.uuid
    end

    test "Validates required fields" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      :user_token_projection
      |> build(context: "reset_password", user: user_projection)
      |> insert()

      {:error, :validation_failure, errors} = UsersContext.reset_password(%{})

      assert errors.password == ["can't be empty"]
      assert errors.token == ["can't be empty"]
      assert errors.uuid == ["can't be empty"]
    end

    test "Validates password_confirmation" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      user_token_projection =
        :user_token_projection
        |> build(context: "reset_password", user: user_projection)
        |> insert()

      {:error, :validation_failure, errors} =
        UsersContext.reset_password(%{
          password: @valid_user_attrs.password,
          password_confirmation: "does not match",
          token: Base.encode64(user_token_projection.token)
        })

      assert errors.password == ["passwords do not match"]
    end

    test "Deletes all of a user's existing tokens" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      :user_token_projection
      |> build(context: "session", user: user_projection)
      |> insert()

      user_reset_password_token_projection =
        :user_token_projection
        |> build(context: "reset_password", user: user_projection)
        |> insert()

      UsersContext.reset_password(%{
        password: @valid_user_attrs.password,
        password_confirmation: @valid_user_attrs.password,
        token: Base.encode64(user_reset_password_token_projection.token)
      })

      result = Repo.all(UserTokenProjection)

      assert result == []
    end
  end
end
