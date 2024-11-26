defmodule ReplyExpress.Accounts.UserTokensContextTest do
  @moduledoc """
  The Accounts context.
  """

  use ReplyExpress.DataCase

  alias ReplyExpress.Accounts.Projections.UserToken, as: UserTokenProjection
  alias ReplyExpress.Accounts.UserTokensContext

  import Ecto.Query, warn: false

  describe "user_session_token_by_user_uuid/1" do
    test "returns UserTokenProjection when exists" do
      user = insert(:user_projection)
      context = "session"

      user_token =
        insert(:user_token_projection, context: context, user_id: user.id, user_uuid: user.uuid)

      %UserTokenProjection{context: result_context, user_uuid: user_uuid} =
        UserTokensContext.user_session_token_by_user_uuid(user_token.user_uuid)

      assert result_context == context
      assert user_uuid == user.uuid
    end
  end
end
