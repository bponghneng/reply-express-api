defmodule ReplyExpress.Accounts.Commands.CreateTeam do
  @moduledoc """
  Command for creating a new team.
  """

  defstruct [:name, :uuid]

  use ExConstructor
  use Vex.Struct

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
end
