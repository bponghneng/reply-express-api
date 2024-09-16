defmodule ReplyExpress.API.V1.Users.ResetPasswordJSONTest do
  use ReplyExpressWeb.ConnCase

  import ReplyExpress.Factory

  alias ReplyExpressWeb.API.V1.Users.ResetPasswordJSON

  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "show/1" do
    test "renders reset password token data" do
      user_projection =
        :user_projection
        |> build(email: @valid_credentials.email)
        |> set_user_projection_password(@valid_credentials.password)
        |> insert()

      context = "reset_password"

      user_token_projection =
        :user_token_projection
        |> build(%{
          context: context,
          user_id: user_projection.id,
          user_uuid: user_projection.uuid
        })
        |> insert()

      expected = %{data: %{context: context, token: Base.encode64(user_token_projection.token)}}

      assert ResetPasswordJSON.show(%{token: user_token_projection}) == expected
    end
  end
end
