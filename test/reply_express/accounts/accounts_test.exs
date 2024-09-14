defmodule ReplyExpress.AccountsTest do
  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection

  @valid_user_attrs %{email: "test@email.local", password: "password1234"}

  describe "log_in_user/1" do
    test "Logs in a registered user from valid email and password" do
      user_projection =
        :user_projection
        |> build(email: @valid_user_attrs.email)
        |> set_user_projection_password(@valid_user_attrs.password)
        |> insert()

      {:ok, %UserTokenProjection{} = user_token} =
        Accounts.log_in_user(%{credentials: @valid_user_attrs})

      assert user_token.user_uuid == user_projection.uuid
    end
  end

  describe "register_user/1" do
    test "Registers new user from valid data" do
      {:ok, %UserProjection{} = user} = Accounts.register_user(@valid_user_attrs)

      assert user.email == @valid_user_attrs.email
    end

    test "Validates email is unique" do
      Accounts.register_user(@valid_user_attrs)

      # Email address already registered
      {:error, :validation_failure, errors} = Accounts.register_user(@valid_user_attrs)

      assert errors == %{email: ["has already been taken"]}
    end

    test "Validates password is at least 8 characters" do
      {:error, :validation_failure, errors} =
        Accounts.register_user(%{@valid_user_attrs | password: "invalid"})

      # Extract message from parameterized error
      assert errors
             |> Map.get(:password)
             |> Enum.at(0)
             |> Keyword.get(:message) == "must be at least 8 characters"
    end
  end
end
