defmodule ReplyExpress.Accounts.Aggregates.UserTest do
  use ReplyExpress.AggregateCase, aggregate: ReplyExpress.Accounts.Aggregates.User

  alias ReplyExpress.Accounts.Events.UserRegistered

  describe "RegisterUser command" do
    test "emits UserRegistered when successful" do
      uuid = UUID.uuid4()
      command = build(:register_user, uuid: uuid)

      assert_events(command, [
        %UserRegistered{
          uuid: uuid,
          email: command.email,
          hashed_password: command.hashed_password
        }
      ])
    end
  end
end
