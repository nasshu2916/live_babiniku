defmodule LiveBabiniku.Tracker do
  use Phoenix.Tracker

  alias LiveBabiniku.Room

  @name __MODULE__
  @tracker_topic "room"
  @rooms_topic LiveBabiniku.Rooms.topic()

  def start_link(opts \\ []) do
    opts = Keyword.merge([name: @name], opts)
    Phoenix.Tracker.start_link(__MODULE__, opts, opts)
  end

  @impl Phoenix.Tracker
  def init(opts) do
    server = Keyword.fetch!(opts, :pubsub_server)
    {:ok, %{pubsub_server: server, node_name: Phoenix.PubSub.node_name(server)}}
  end

  @impl Phoenix.Tracker
  def handle_diff(diff, state) do
    for {topic, topic_diff} <- diff do
      handle_topic_diff(topic, topic_diff, state)
    end

    {:ok, state}
  end

  @doc """
  Returns all tracked rooms.
  """
  @spec list_rooms() :: [Room.t()]
  def list_rooms() do
    presences = Phoenix.Tracker.list(@name, @tracker_topic)
    for {_id, %{room: room}} <- presences, do: room
  end

  @doc """
  Returns tracked room with the given id.
  """
  @spec fetch_room(String.t()) :: {:ok, Room.t()} | :error
  def fetch_room(id) do
    case Phoenix.Tracker.get_by_key(@name, @tracker_topic, id) do
      [{_id, %{room: room}}] -> {:ok, room}
      _ -> :error
    end
  end

  @doc """
  Starts tracking the given room, making it visible globally.
  """
  @spec track_room(Room.t()) :: :ok | {:error, any()}
  def track_room(room) do
    case Phoenix.Tracker.track(@name, room.pid, @tracker_topic, room.id, %{
           room: room
         }) do
      {:ok, _ref} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Updates the tracked room object matching the given id.
  """
  @spec update_room(Room.t()) :: :ok | {:error, any()}
  def update_room(room) do
    case Phoenix.Tracker.update(@name, room.pid, @tracker_topic, room.id, %{
           room: room
         }) do
      {:ok, _ref} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp handle_topic_diff(@tracker_topic, {joins, leaves}, state) do
    joins = Map.new(joins)
    leaves = Map.new(leaves)

    messages =
      for id <- Enum.uniq(Map.keys(joins) ++ Map.keys(leaves)) do
        case {joins[id], leaves[id]} do
          {%{room: room}, nil} -> {:room_created, room}
          {nil, %{room: room}} -> {:room_closed, room}
          {%{room: room}, %{}} -> {:room_updated, room}
        end
      end

    for message <- messages do
      Phoenix.PubSub.direct_broadcast!(
        state.node_name,
        state.pubsub_server,
        @rooms_topic,
        message
      )
    end
  end
end
