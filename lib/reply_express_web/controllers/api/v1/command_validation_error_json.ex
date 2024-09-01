defmodule ReplyExpressWeb.API.V1.CommandValidationErrorJSON do
  @moduledoc """
  Renders command validation errors
  """

  def errors(%{errors: errors}) do
    data =
      errors
      |> Enum.map(&data/1)
      |> Enum.into(%{})

    %{errors: data}
  end

  defp data({:error, field, _, message} = _error) when is_list(message) do
    {field, [Keyword.get(message, :message)]}
  end

  defp data({:error, field, _, message} = _error) do
    {field, [message]}
  end
end
