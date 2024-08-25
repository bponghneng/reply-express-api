defmodule ReplyExpressWeb.API.V1.InboundController do
  use ReplyExpressWeb, :controller

  def create(conn, params) do
    json(conn, params)
  end
end
