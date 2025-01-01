defmodule ReplyExpressWeb.API.V1.FallbackController do
  use Phoenix.Controller

  alias Ecto.Changeset
  alias ReplyExpressWeb.API.V1.ErrorJSON
  alias ReplyExpressWeb.API.V1.ChangesetJSON
  alias ReplyExpressWeb.API.V1.CommandValidationErrorJSON

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(403)
    |> put_view(json: ErrorJSON)
    |> render(:"403")
  end

  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :validation_failure, _} = error) do
    {_, _, validation_errors} = error

    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CommandValidationErrorJSON)
    |> render(:errors, errors: validation_errors)
  end

  def call(conn, _error) do
    conn
    |> put_status(500)
    |> put_view(json: ErrorJSON)
    |> render(:"500")
  end
end
