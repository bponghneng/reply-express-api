defmodule ReplyExpress.Accounts.Commands.LogInUser do
  @moduledoc """
  Command to log in a registered user, including sanitization and validation fns
  """

  defstruct credentials: nil,
            logged_in_at: nil,
            uuid: ""

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext
  alias ReplyExpress.Accounts.Validators.ValidCredentials

  validates(:credentials, presence: [message: "can't be empty"], by: &ValidCredentials.validate/2)

  def set_logged_in_at(%LogInUser{} = log_in_user) do
    %LogInUser{log_in_user | logged_in_at: Timex.now()}
  end

  def set_uuid(%LogInUser{} = log_in_user) do
    uuid =
      log_in_user
      |> user_by_email()
      |> case do
        %UserProjection{} = user_projection -> user_projection.uuid
        _ -> nil
      end

    %LogInUser{log_in_user | uuid: uuid}
  end

  defp user_by_email(%LogInUser{} = log_in_user) do
    UsersContext.user_by_email(log_in_user.credentials.email)
  end
end
