defmodule ReplyExpress.API.V1.UserRegistrationJSONTest do
  use ReplyExpressWeb.ConnCase, async: true

  import ReplyExpress.Factories

  alias ReplyExpressWeb.API.V1.UserRegistrationJSON

  describe "show/1" do
    test "renders registered user data" do
      user = build(:user) |> set_user_password("password1234") |> insert()

      expected = %{
        data: %{
          confirmed_at: user.confirmed_at,
          email: user.email,
          inserted_at: user.inserted_at,
          updated_at: user.updated_at,
          uuid: user.uuid
        }
      }

      assert UserRegistrationJSON.show(%{user: user}) == expected
    end
  end
end
