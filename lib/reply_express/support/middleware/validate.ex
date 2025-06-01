defmodule ReplyExpress.Support.Middleware.Validate do
  @moduledoc """
  Middleware for Commanded pipelines that validates commands using Vex before dispatch.

  This middleware checks if the command struct is valid according to Vex validations. If valid, the pipeline continues as normal. If invalid, it halts the pipeline and responds with detailed validation errors grouped by field.

  Usage:
    Add this middleware to your Commanded pipeline to enforce validation on incoming commands.
  """

  @behaviour Commanded.Middleware

  alias Commanded.Middleware.Pipeline
  import Pipeline

  def before_dispatch(%Pipeline{command: command} = pipeline) do
    case Vex.valid?(command) do
      true -> pipeline
      false -> failed_validation(pipeline)
    end
  end

  def after_dispatch(pipeline), do: pipeline
  def after_failure(pipeline), do: pipeline

  defp failed_validation(%Pipeline{command: command} = pipeline) do
    errors = command |> Vex.errors() |> merge_errors()

    pipeline
    |> respond({:error, :validation_failure, errors})
    |> halt()
  end

  defp merge_errors(errors) do
    errors
    |> Enum.group_by(
      fn {_error, field, _type, _message} -> field end,
      fn {_error, _field, _type, message} -> message end
    )
    |> Map.new()
  end
end
