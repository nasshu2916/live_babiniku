defmodule LiveBabinikuWeb.Plug.UserPlug do
  @behaviour Plug

  import Plug.Conn

  alias LiveBabiniku.User

  @current_user_key :current_user

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    conn
    |> ensure_current_user()
  end

  defp ensure_current_user(conn) do
    if get_session(conn, @current_user_key) do
      conn
    else
      user = User.new()
      put_session(conn, @current_user_key, user)
    end
  end
end
