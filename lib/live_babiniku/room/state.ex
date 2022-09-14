defmodule LiveBabiniku.Room.State do
  alias LiveBabiniku.User
  alias LiveBabiniku.Room.State.Data

  defstruct [
    :room_id,
    :name,
    :private?,
    :data,
    :raw_top_message,
    :top_message,
    :owner_user_id,
    :created_at,
    :last_updated_at
  ]

  @type t :: %__MODULE__{
          room_id: room_id(),
          name: String.t(),
          private?: boolean,
          data: Data.t(),
          raw_top_message: String.t(),
          top_message: String.t(),
          owner_user_id: User.id(),
          created_at: DateTime.t(),
          last_updated_at: DateTime.t()
        }
  @type room_id :: String.t()
  @type operation ::
          {:client_join, pid, User.t()} | {:client_leave, pid} | {:update_top_message, String.t(), String.t()}

  @spec new(room_id(), String.t(), Keyword.t()) :: t()
  def new(room_id, name, opts) do
    now = DateTime.utc_now()

    %__MODULE__{
      room_id: room_id,
      name: name,
      private?: Keyword.get(opts, :private?, true),
      data: Data.new(),
      raw_top_message: "",
      top_message: "",
      owner_user_id: Keyword.fetch!(opts, :owner_user_id),
      created_at: now,
      last_updated_at: now
    }
  end

  @spec apply_operation(t(), operation()) :: {:ok, t()} | :error
  def apply_operation(state, {:client_join, client_pid, user}) do
    if Map.has_key?(state.data.clients_map, client_pid) do
      :error
    else
      new_data = Data.client_join(state.data, client_pid, user)
      {:ok, update_state(state, data: new_data)}
    end
  end

  def apply_operation(state, {:client_leave, client_pid}) do
    if Map.has_key?(state.data.clients_map, client_pid) do
      new_data = Data.client_leave(state.data, client_pid)
      {:ok, update_state(state, data: new_data)}
    else
      :error
    end
  end

  def apply_operation(state, {:update_top_message, raw_message, message}) do
    {:ok, update_state(state, raw_top_message: raw_message, top_message: message)}
  end

  defp update_state(state, update_keyword) do
    Enum.reduce(update_keyword, state, fn {key, value}, state ->
      Map.replace!(state, key, value)
    end)
    |> Map.replace!(:last_updated_at, DateTime.utc_now())
  end
end
