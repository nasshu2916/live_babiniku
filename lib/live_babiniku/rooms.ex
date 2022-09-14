defmodule LiveBabiniku.Rooms do
  alias LiveBabiniku.{Room, Tracker}

  @room_length 12
  @topic inspect(__MODULE__)

  @spec list :: [Room.t()]
  def list() do
    Tracker.list_rooms()
  end

  @spec fetch(String.t()) :: {:ok, Room.t()} | :error
  def fetch(id) do
    Tracker.fetch_room(id)
  end

  @spec create(String.t(), Keyword.t()) :: {:ok, Room.t()} | {:error, any()}
  def create(name, opts \\ []) do
    id = :crypto.strong_rand_bytes(@room_length) |> Base.encode32(case: :lower, padding: false)

    opts = Keyword.put_new(opts, :id, id) |> Keyword.put(:name, name)

    case DynamicSupervisor.start_child(LiveBabiniku.RoomSupervisor, {Room, opts}) do
      {:ok, pid} ->
        room = Room.get_by_pid(pid)

        case Tracker.track_room(room) do
          :ok ->
            {:ok, room}

          {:error, reason} ->
            Room.close(pid)
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def topic(), do: @topic
  @spec subscribe :: :ok | {:error, term()}
  def subscribe do
    Phoenix.PubSub.subscribe(LiveBabiniku.PubSub, @topic)
  end
end
