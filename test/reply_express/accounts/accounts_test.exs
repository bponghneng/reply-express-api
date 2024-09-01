defmodule ReplyExpress.AccountsTest do
  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Projections.User

  describe "register_user/1" do
    test "Registers new user from valid data" do
      email = "test@email.local"

      {:ok, %User{} = user} = Accounts.register_user(%{email: email, password: "passwor"})

      assert user.email == email
    end

    test "Validates email is unique" do
      email = "test@email.local"

      Accounts.register_user(%{email: email, password: "password1234"})

      # Email address already registered
      {:error, [{:error, field, _validation, message}]} =
        Accounts.register_user(%{email: email, password: "password1234"})

      assert field == :email
      assert message == "has already been taken"
    end
  end
end
