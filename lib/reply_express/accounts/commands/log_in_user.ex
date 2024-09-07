defmodule ReplyExpress.Accounts.Commands.LogInUser do
  @moduledoc """
  Command to log in a registered user, including sanitization and validation fns
  """

  defstruct credentials: nil,
            email: "",
            hashed_password: "",
            logged_in_at: nil,
            uuid: ""

  use ExConstructor
  use Vex.Struct

  alias ReplyExpress.Accounts
  alias ReplyExpress.Accounts.Commands.LogInUser
  alias ReplyExpress.Accounts.Projections.User, as: UserProjection
  alias ReplyExpress.Accounts.Validators.ValidCredentials

  validates(:credentials, presence: [message: "can't be empty"], by: &ValidCredentials.validate/2)

  @doc """
  Map lowercased email, hashed_password into credentials
  """
  def build_credentials(%LogInUser{} = log_in_user) do
    %LogInUser{email: email, hashed_password: hashed_password} = log_in_user

    %LogInUser{
      log_in_user
      | credentials: %{email: String.downcase(email), hashed_password: hashed_password}
    }
  end

  def set_logged_in_at(%LogInUser{} = log_in_user) do
    %LogInUser{log_in_user | logged_in_at: Timex.now()}
  end

  def set_uuid(%LogInUser{} = log_in_user) do
    uuid =
      log_in_user
      |> Map.get(:email)
      |> Accounts.user_by_email()
      |> case do
        %UserProjection{} = user_projection -> user_projection.uuid
        _ -> nil
      end

    %LogInUser{log_in_user | uuid: uuid}
  end
end
