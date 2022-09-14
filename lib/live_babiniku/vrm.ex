defmodule LiveBabiniku.Vrm do
  @topic_prefix inspect(__MODULE__)

  @spec subscribe(String.t()) :: :ok | {:error, term()}
  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(LiveBabiniku.PubSub, topic(room_id))
  end

  @spec broadcast(String.t(), atom, map) :: :ok
  def broadcast(room_id, event, params) do
    Phoenix.PubSub.broadcast(LiveBabiniku.PubSub, topic(room_id), {event, params})
    :ok
  end

  defp topic(room_id) do
    "#{@topic_prefix}:#{room_id}"
  end
end
