defmodule LiveBabinikuWeb.HealthController do
  use LiveBabinikuWeb, :controller

  def index(conn, _params) do
    json(conn, %{})
  end
end
