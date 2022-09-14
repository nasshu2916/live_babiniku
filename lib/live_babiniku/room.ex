defmodule LiveBabiniku.Room do
  use GenServer, restart: :temporary

  alias LiveBabiniku.User
  alias LiveBabiniku.Room.State

  @auto_shutdown_millisecond 10 * 1000

  defstruct [
    :id,
    :name,
    :private?,
    :pid
  ]

  @timeout 5000
  @topic_prefix "#{__MODULE__}:"

  @type t :: %__MODULE__{
          id: room_id,
          name: String.t(),
          private?: boolean,
          pid: pid()
        }
  @type room_id :: String.t()

  @spec subscribe(room_id()) :: :ok | {:error, term()}
  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(LiveBabiniku.PubSub, @topic_prefix <> room_id)
  end

  @spec start_link(Keyword.t()) :: {:ok, pid} | {:error, any()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @doc """
  room pid からルームの Room を取得する
  """
  @spec get_by_pid(pid) :: t()
  def get_by_pid(room_pid) do
    GenServer.call(room_pid, :describe_self, @timeout)
  end

  @doc """
  room pid からルームの State を取得する
  """
  @spec get_state(pid()) :: State.t()
  def get_state(room_pid) do
    GenServer.call(room_pid, :get_state, @timeout)
  end

  @doc """
  room プロセスにクライアントユーザーを登録する
  """
  @spec register_client(pid(), pid(), User.t()) :: State.t()
  def register_client(room_pid, client_pid, user) do
    GenServer.call(room_pid, {:register_client, client_pid, user}, @timeout)
  end

  @doc """
  room の top message を更新する
  """
  @spec update_top_message(pid(), String.t(), String.t()) :: :ok
  def update_top_message(room_pid, raw_message, message) do
    GenServer.cast(room_pid, {:update_top_message, raw_message, message})
  end

  @doc """
  room を閉じる
  """
  @spec close(pid) :: :ok
  def close(room_pid) do
    _ = call_many(List.wrap(room_pid), :close)
    :ok
  end

  @impl GenServer
  def init(opts) do
    id = Keyword.fetch!(opts, :id)
    name = Keyword.fetch!(opts, :name)
    state = init_state(id, name, opts)
    {:ok, state}
  end

  @impl GenServer
  def handle_call(:describe_self, _from, state) do
    {:reply, self_from_state(state), state}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call(:close, _from, state) do
    # TODO: Room が閉じた時にメッセージを送る
    # broadcast_message(state.room_id, :room_closed)

    {:stop, :shutdown, :ok, state}
  end

  @impl GenServer
  def handle_call({:register_client, client_pid, user}, _from, state) do
    Process.monitor(client_pid)

    state = handle_operation(state, {:client_join, client_pid, user})

    {:reply, state, state}
  end

  @impl GenServer
  def handle_cast({:update_top_message, raw_message, message}, state) do
    state = handle_operation(state, {:update_top_message, raw_message, message})
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:DOWN, _ref, :process, client_pid, _}, state) do
    state = handle_operation(state, {:client_leave, client_pid})

    if state.data.clients_map |> Map.keys() |> Enum.empty?() do
      Process.send_after(self(), {:auto_shutdown, state.last_updated_at}, @auto_shutdown_millisecond)
    end

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:auto_shutdown, scheduled_last_updated_at}, state) do
    if DateTime.compare(scheduled_last_updated_at, state.last_updated_at) == :eq do
      :gen_server.send_request(self(), :close)
    end

    {:noreply, state}
  end

  @spec init_state(String.t(), String.t(), Keyword.t()) :: State.t()
  defp init_state(id, name, opts) do
    State.new(id, name, opts)
  end

  defp self_from_state(state) do
    %__MODULE__{
      id: state.room_id,
      name: state.name,
      private?: state.private?,
      pid: self()
    }
  end

  @spec handle_operation(State.t(), State.operation()) :: State.t()
  defp handle_operation(state, operation) do
    case State.apply_operation(state, operation) do
      {:ok, new_state} ->
        broadcast_message(state.room_id, {:update_state, new_state})
        new_state

      # |> after_operation(state, operation)
      # |> handle_actions(actions)

      :error ->
        state
    end
  end

  defp call_many(list, request) do
    list
    |> Enum.map(&:gen_server.send_request(&1, request))
    |> Enum.map(&:gen_server.wait_response(&1, :infinity))
  end

  defp broadcast_message(room_id, message) do
    Phoenix.PubSub.broadcast(LiveBabiniku.PubSub, @topic_prefix <> room_id, message)
  end
end
