defmodule LiveBabiniku.User do
  defstruct [:id, :name]

  @type t :: %__MODULE__{
          id: id(),
          name: String.t() | nil
        }
  @type id :: String.t()

  @default_random_id_length 20

  @spec new() :: t()
  def new() do
    %__MODULE__{
      id: random_id(),
      name: nil
    }
  end

  @spec random_id() :: id()
  defp random_id() do
    :crypto.strong_rand_bytes(@default_random_id_length) |> Base.encode32(case: :lower)
  end
end
