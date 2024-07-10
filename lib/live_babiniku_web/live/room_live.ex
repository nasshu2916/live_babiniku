defmodule LiveBabinikuWeb.RoomLive do
  use LiveBabinikuWeb, :live_view

  alias LiveBabiniku.{Room, Rooms, Vrm}
  alias Phoenix.LiveView.JS

  @impl Phoenix.LiveView
  def mount(%{"room_id" => room_id}, _session, socket) do
    %{assigns: %{current_user: user}} = socket

    if connected?(socket) do
      LiveBabiniku.Vrm.subscribe(room_id)
    end

    case Rooms.fetch(room_id) do
      {:ok, room} ->
        state =
          if connected?(socket) do
            state = Room.register_client(room.pid, self(), socket.assigns.current_user)
            Room.subscribe(room_id)

            state
          else
            Room.get_state(room.pid)
          end

        room_url = room_url(room.id, socket)
        own_room? = own_room?(user.id, state)

        {:ok,
         assign(
           socket,
           page_title: "ルーム: #{room.name}",
           room: room,
           state: state,
           room_url: room_url,
           own_room?: own_room?
         )}

      :error ->
        {:ok,
         push_navigate(
           socket,
           to: Routes.home_path(socket, :page)
         )}
    end
  end

  @impl Phoenix.LiveView
  def handle_params(%{"room_id" => room_id}, _url, %{assigns: %{live_action: :event, own_room?: false}} = socket) do
    {:noreply, push_patch(socket, to: Routes.room_path(socket, :page, room_id))}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("change_top_message", %{"top_message" => message} = _params, socket) do
    message = String.trim(message)

    with true <- socket.assigns.own_room?,
         {:ok, html, _} <- Earmark.as_html(message, compact_output: true) do
      socket |> room_pid() |> Room.update_top_message(message, html)
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("change", params, socket) do
    if socket.assigns.own_room? do
      Vrm.broadcast(socket.assigns.room.id, :change, params)
    end

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:update_state, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  @impl Phoenix.LiveView
  def handle_info({:change, params}, socket) do
    {:noreply, push_event(socket, "changeRotation", params)}
  end

  defp tracking_control_button(assigns) do
    ~H"""
    <div id="tracking-control-button" class="absolute p-3 bottom-3 right-3">
      <button
        id="start-tracking-button"
        phx-click={
          JS.dispatch("start_tracking", to: "#tracking")
          |> JS.add_class("now-tracking", to: "#tracking-control-button")
          |> JS.show(to: "#tracking", display: "flex")
        }
      >
        <.icon icon="videocam" class="text-4xl" />
      </button>
      <button
        id="stop-tracking-button"
        class="hidden"
        phx-click={
          JS.dispatch("stop_tracking", to: "#tracking")
          |> JS.remove_class("now-tracking", to: "#tracking-control-button")
          |> JS.hide(to: "#tracking")
        }
      >
        <.icon icon="videocam_off" class="text-4xl" />
      </button>
    </div>
    """
  end

  @spec room_pid(Phoenix.LiveView.Socket.t()) :: pid
  defp room_pid(socket) do
    socket.assigns.room.pid
  end

  defp room_url(room_id, socket) do
    Routes.room_url(socket, :page, room_id)
  end

  defp own_room?(user_id, state) do
    state.owner_user_id == user_id
  end
end
