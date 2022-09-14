defmodule LiveBabinikuWeb.HomeLive do
  use LiveBabinikuWeb, :live_view

  alias LiveBabiniku.Rooms

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket) do
      LiveBabiniku.Rooms.subscribe()
    end

    rooms = Rooms.list()

    {:ok, assign(socket, page_title: "ルーム一覧", rooms: rooms, create_room_name: "")}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"data" => %{"name" => name}}, socket) do
    {:noreply, assign(socket, create_room_name: name)}
  end

  @impl Phoenix.LiveView
  def handle_event("create_room", %{"data" => %{"name" => name, "private" => private}}, socket) do
    user = socket.assigns.current_user

    case Rooms.create(name, owner_user_id: user.id, private?: private == "true") do
      {:ok, room} ->
        {:noreply, push_redirect(socket, to: Routes.room_path(socket, :page, room.id))}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:room_created, room}, socket) do
    if room in socket.assigns.rooms do
      {:noreply, socket}
    else
      {:noreply, assign(socket, rooms: [room | socket.assigns.rooms])}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:room_updated, room}, socket) do
    rooms =
      Enum.map(socket.assigns.rooms, fn other ->
        if other.id == room.id, do: room, else: other
      end)

    {:noreply, assign(socket, rooms: rooms)}
  end

  @impl Phoenix.LiveView
  def handle_info({:room_closed, room}, socket) do
    rooms = Enum.reject(socket.assigns.rooms, &(&1.id == room.id))
    {:noreply, assign(socket, rooms: rooms)}
  end

  defp room(assigns) do
    ~H"""
    <div class="p-3 grid grid-cols-2 gap-4 border-base-content border-2 border-opacity-10 rounded-lg items-center">
      <div class="col-auto">
        <div>
          <span>ルーム名:</span><span><%= @room.name %></span>
        </div>
      </div>
      <div class="col-end-auto flex justify-end">
        <%= live_redirect to: Routes.room_path(@socket, :page, @room.id), class: "btn btn-sm" do %>
          <.icon icon="login" />
        <% end %>
      </div>
    </div>
    """
  end
end
