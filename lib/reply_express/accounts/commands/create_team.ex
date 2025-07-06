defmodule ReplyExpress.Accounts.Commands.CreateTeam do
  @moduledoc """
  Command for creating a new team.
  """

  use ExConstructor
  use Vex.Struct

  @type t :: %__MODULE__{
    name: String.t(),
    uuid: String.t(),
    user_registration_uuid: String.t() | nil
  }

  defstruct [:name, :uuid, :user_registration_uuid]

  validates :name, presence: [message: "can't be empty"]
  validates :uuid, presence: [message: "can't be empty"]

  @doc """
  Sets the name for the team.
  """
  def set_name(%__MODULE__{} = command, name) do
    %{command | name: name}
  end

  @doc """
  Sets the UUID for the team.
  """
  def set_uuid(%__MODULE__{} = command, uuid) do
    %{command | uuid: uuid}
  end

  @doc """
  Sets the user registration UUID for the team.
  """
  def set_user_registration_uuid(%__MODULE__{} = command, user_registration_uuid) do
    %{command | user_registration_uuid: user_registration_uuid}
  end
end
