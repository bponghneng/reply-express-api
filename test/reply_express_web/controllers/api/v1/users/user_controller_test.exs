defmodule ReplyExpressWeb.API.V1.Users.UserControllerTest do
  use ReplyExpressWeb.ConnCase

  alias ReplyExpress.Accounts.Projections.User, as: UserProjection

  describe "POST /api/v1/users" do
    test "creates user when data is valid", %{conn: conn} do
      user_params = %{
        "email" => "test@example.com",
        "password" => "password123"
      }

      result =
        conn
        |> post(~p"/api/v1/users", %{"user" => user_params})
        |> json_response(201)

      assert %{"data" => %{"uuid" => uuid, "email" => "test@example.com"}} = result
      assert Repo.get_by(UserProjection, uuid: uuid)
    end

    test "renders errors when email is invalid", %{conn: conn} do
      user_params = %{
        "email" => "invalid-email",
        "password" => "password123"
      }

      result =
        conn
        |> post(~p"/api/v1/users", %{"user" => user_params})
        |> json_response(422)

      assert result["errors"]["email"] == ["is invalid"]
    end

    test "renders errors when password is too short", %{conn: conn} do
      user_params = %{
        "email" => "test@example.com",
        "password" => "short"
      }

      result =
        conn
        |> post(~p"/api/v1/users", %{"user" => user_params})
        |> json_response(422)

      assert result["errors"]["password"] == ["must be at least 8 characters"]
    end

    test "renders errors when email already exists", %{conn: conn} do
      # Create a user first
      existing_email = "existing@example.com"

      user_params = %{
        "email" => existing_email,
        "password" => "password123"
      }

      # First request should succeed
      first_result =
        conn
        |> post(~p"/api/v1/users", %{"user" => user_params})
        |> json_response(201)

      assert first_result["data"]["email"] == existing_email

      # Second request with same email should fail
      second_result =
        conn
        |> post(~p"/api/v1/users", %{"user" => user_params})
        |> json_response(422)

      assert second_result["errors"]["email"] == ["has already been taken"]
    end

    test "handles empty POST body", %{conn: conn} do
      result =
        conn
        |> post(~p"/api/v1/users", %{})
        |> json_response(422)

      assert result["errors"]["user"] == ["is required"]
    end

    @tag :skip
    test "handles empty user params", %{conn: conn} do
      result =
        conn
        |> post(~p"/api/v1/users", %{"user" => %{}})
        |> json_response(422)

      assert result["errors"]["email"]
      assert result["errors"]["password"]
    end
  end
end
