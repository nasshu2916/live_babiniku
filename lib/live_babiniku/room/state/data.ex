defmodule LiveBabiniku.Room.State.Data do
  alias LiveBabiniku.User

  defstruct [:clients_map]

  @type t :: %__MODULE__{
          clients_map: %{pid => User.t()}
        }

  @spec new() :: t()
  def new() do
    %__MODULE__{
      clients_map: %{}
    }
  end

  @spec client_join(t(), pid, User.t()) :: t()
  def client_join(data, client_pid, user) do
    recursive_update(data, %{clients_map: &Map.put_new(&1, client_pid, user)})
  end

  def client_leave(data, client_pid) do
    recursive_update(data, %{clients_map: &Map.delete(&1, client_pid)})
  end

  defp recursive_update(data, updater) when is_function(updater), do: updater.(data)

  defp recursive_update(data, updater) do
    for {key, value} <- updater, reduce: data do
      data -> Map.put(data, key, Map.get(data, key) |> recursive_update(value))
    end
  end
end
