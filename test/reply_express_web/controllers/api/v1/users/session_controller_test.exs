defmodule ReplyExpressWeb.API.V1.Users.SessionControllerTest do
  @moduledoc false

  use ReplyExpressWeb.ConnCase

  alias Commanded.EventStore
  alias Commanded.EventStore.EventData
  alias Commanded.EventStore.TypeProvider
  alias ReplyExpress.Accounts.Commands.CreateUser
  alias ReplyExpress.Accounts.Events.UserRegistered
  alias ReplyExpress.Accounts.Projections.UserToken
  alias ReplyExpress.Commanded
  alias ReplyExpress.Repo

  @invalid_credentials %{email: "test@email", password: "1234"}
  @valid_credentials %{email: "test@email.local", password: "password1234"}

  describe "POST /api/v1/users/login" do
    test "sets cookie with token for session tracking", context do
      command = %CreateUser{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        uuid: UUID.uuid4()
      }

      :ok = Commanded.dispatch(command, consistency: :strong)

      response =
        post(context.conn, ~p"/api/v1/users/login", %{"credentials" => @valid_credentials})

      token = UserToken |> Repo.one() |> Map.get(:token)

      assert response.cookies["session"] == token
    end

    test "renders errors for invalid data", context do
      causation_id = UUID.uuid4()
      correlation_id = UUID.uuid4()

      user_uuid = UUID.uuid4()

      event = %UserRegistered{
        email: @valid_credentials.email,
        hashed_password: Pbkdf2.hash_pwd_salt(@valid_credentials.password),
        uuid: user_uuid
      }

      event_data =
        [
          %EventData{
            causation_id: causation_id,
            correlation_id: correlation_id,
            event_type: TypeProvider.to_string(event),
            data: event,
            metadata: %{}
          }
        ]

      :ok = EventStore.append_to_stream(Commanded, user_uuid, 0, event_data)

      response =
        context.conn
        |> post(~p"/api/v1/users/login", %{"credentials" => @invalid_credentials})
        |> json_response(422)

      assert response["errors"]["credentials"] == ["are invalid"]
    end

    test "handles empty POST body", context do
      response =
        context.conn
        |> post(~p"/api/v1/users/login", %{})
        |> json_response(422)

      assert response["errors"]["credentials"] == ["is required"]
    end
  end
end
