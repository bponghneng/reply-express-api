defmodule ReplyExpressWeb.API.V1.CommandValidationErrorJSONTest do
  use ReplyExpressWeb.ConnCase, async: true

  alias ReplyExpressWeb.API.V1.CommandValidationErrorJSON

  describe "error/1" do
    test "renders error with string message" do
      message = "has already been taken"
      errors = [{:error, :email, :by, message}]

      assert CommandValidationErrorJSON.errors(%{errors: errors}) == %{
               errors: %{email: [message]}
             }
    end

    test "renders error with keyword list message" do
      message = "must be at least 8 characters"

      errors = [
        {:error, :password, :length, [message: "must be at least 8 characters"]}
      ]

      assert CommandValidationErrorJSON.errors(%{errors: errors}) == %{
               errors: %{password: [message]}
             }
    end
  end
end
