defmodule ReplyExpress.Accounts.Commands.LogInUser do
  @moduledoc """
  Command to log in a registered user, including sanitization and validation fns
  """

  defstruct [:id, credentials: nil, logged_in_at: nil, uuid: ""]

  @type t :: %__MODULE__{
          id: integer,
          credentials: map,
          logged_in_at: DateTime.t(),
          uuid: String.t()
        }

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

  @spec set_id_and_uuid(LogInUser.t()) :: LogInUser.t()
  def set_id_and_uuid(%LogInUser{} = log_in_user) do
    %{id: id, uuid: uuid} =
      log_in_user
      |> user_by_email()
      |> case do
        %UserProjection{} = user_projection ->
          %{id: user_projection.id, uuid: user_projection.uuid}

        _ ->
          %{id: nil, uuid: ""}
      end

    %LogInUser{log_in_user | id: id, uuid: uuid}
  end

  defp user_by_email(%LogInUser{} = log_in_user) do
    UsersContext.user_by_email(log_in_user.credentials.email)
  end
end
