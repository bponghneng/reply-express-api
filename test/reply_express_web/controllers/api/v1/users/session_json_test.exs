defmodule ReplyExpress.API.V1.Users.SessionJSONTest do
  use ReplyExpressWeb.ConnCase

  import ReplyExpress.Factory

  alias ReplyExpressWeb.API.V1.Users.SessionJSON

  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "show/1" do
    test "renders user log_in data" do
      user_projection =
        :user_projection
        |> build(email: @valid_credentials.email)
        |> set_user_projection_password(@valid_credentials.password)
        |> insert()

      context = "session"

      user_token_projection =
        :user_token_projection
        |> build(%{
          context: context,
          user_id: user_projection.id,
          user_uuid: user_projection.uuid
        })
        |> insert()

      expected = %{data: %{context: context, token: Base.encode64(user_token_projection.token)}}

      assert SessionJSON.show(%{token: user_token_projection}) == expected
    end
  end
end
