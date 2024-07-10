defmodule LiveBabinikuWeb.ErrorViewTest do
  use LiveBabinikuWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(LiveBabinikuWeb.ErrorView, "404.html", "html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(LiveBabinikuWeb.ErrorView, "500.html", "html", []) == "Internal Server Error"
  end
end
