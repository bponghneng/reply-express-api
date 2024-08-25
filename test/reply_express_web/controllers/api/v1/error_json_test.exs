defmodule ReplyExpressWeb.API.V1.ErrorJSONTest do
  use ReplyExpressWeb.ConnCase, async: true

  alias ReplyExpressWeb.API.V1.ErrorJSON

  test "renders 404" do
    assert ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert ErrorJSON.render("500.json", %{}) == %{errors: %{detail: "Internal Server Error"}}
  end
end
