defmodule ReplyExpress.Accounts.Validators.LoggedInAtNotExpired do
  @moduledoc """
  Custom Vex.Validator to validate that a logged_in_at date is not more than 1 hour ago
  """

  use Vex.Validator

  @doc """
  Returns an error tuple with message if a logged_in_date is more than 1 hour ago and `:ok` if not
  """
  def validate(value, _context) do
    case more_than_one_hour_elapsed?(value) do
      true -> {:error, "has expired"}
      false -> :ok
    end
  end

  defp more_than_one_hour_elapsed?(logged_in_at) do
    one_hour_ago = Timex.shift(Timex.now(), minutes: 60)
    Timex.diff(logged_in_at, one_hour_ago, :minutes) > 60
  end
end
