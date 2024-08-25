defmodule ReplyExpress.Factories.User do
  alias ReplyExpress.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory() do
        %User{email: sequence(:email, &"test-#{&1}@email.local")}
      end

      def set_user_password(%User{} = user, password) do
        %{user | hashed_password: Pbkdf2.hash_pwd_salt(password)}
      end
    end
  end
end
