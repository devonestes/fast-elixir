defmodule RetrieveState.Fast do
  def get_state(ets_pid) do
    :ets.lookup(ets_pid, :stored_state)
  end
end

defmodule StateHolder do
  use GenServer

  def init(_), do: {:ok, %{stored_state: :returned_state}}

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def get_state(key), do: GenServer.call(__MODULE__, {:get_state, key})

  def handle_call({:get_state, key}, _from, state), do: {:reply, state[key], state}
end

defmodule RetrieveState.Slow do
  def get_state do
    StateHolder.get_state(:stored_state)
  end
end

defmodule RetrieveState.Benchmark do
  def benchmark do
    ets_pid = :ets.new(:state_store, [:set, :public])
    :ets.insert(ets_pid, {:stored_state, :returned_state})
    StateHolder.start_link()

    Benchee.run(
      %{
        "ets table" => fn -> RetrieveState.Fast.get_state(ets_pid) end,
        "gen server" => fn -> RetrieveState.Slow.get_state() end
      },
      time: 10,
      print: [fast_warning: false]
    )
  end
end

RetrieveState.Benchmark.benchmark()
