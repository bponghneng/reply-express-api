defmodule ReplyExpress.API.V1.Users.UserJSONTest do
  use ReplyExpressWeb.ConnCase

  import ReplyExpress.Factory

  alias ReplyExpressWeb.API.V1.Users.UserJSON

  describe "show/1" do
    test "renders user data" do
      user = build(:user_projection)

      expected = %{
        data: %{
          confirmed_at: user.confirmed_at,
          email: user.email,
          inserted_at: user.inserted_at,
          updated_at: user.updated_at,
          uuid: user.uuid
        }
      }

      assert UserJSON.show(%{user: user}) == expected
    end
  end
end
