defmodule ReplyExpress.Accounts.Commands.Login do
  @moduledoc """
  Command to log in a registered user, including sanitization and validation fns
  """

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts.Commands.Login
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.UsersContext
  alias ReplyExpress.Accounts.Validators.ValidCredentials

  @type t :: %__MODULE__{
          id: integer,
          credentials: map,
          logged_in_at: DateTime.t(),
          uuid: String.t()
        }

  defstruct [:id, credentials: nil, logged_in_at: nil, uuid: ""]

  validates(:credentials, presence: [message: "can't be empty"], by: &ValidCredentials.validate/2)

  def set_logged_in_at(%Login{} = login) do
    %Login{login | logged_in_at: Timex.now()}
  end

  @spec set_id_and_uuid(Login.t()) :: Login.t()
  def set_id_and_uuid(%Login{} = login) do
    %{id: id, uuid: uuid} =
      login
      |> user_by_email()
      |> case do
        %UserProjection{} = user_projection ->
          %{id: user_projection.id, uuid: user_projection.uuid}

        _ ->
          %{id: nil, uuid: ""}
      end

    %Login{login | id: id, uuid: uuid}
  end

  defp user_by_email(%Login{} = login) do
    UsersContext.user_by_email(login.credentials.email)
  end
end
