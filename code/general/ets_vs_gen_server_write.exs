defmodule RetrieveState.Fast do
  def put_state(ets_pid, state) do
    :ets.insert(ets_pid, {:stored_state, state})
  end
end

defmodule StateHolder do
  use GenServer

  def init(_), do: {:ok, %{}}

  def start_link(state \\ []), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def put_state(value), do: GenServer.call(__MODULE__, {:put_state, value})

  def handle_call({:put_state, value}, _from, state), do: {:reply, true, Map.put(state, :stored_state, value)}
end

defmodule RetrieveState.Medium do
  def put_state(value) do
    StateHolder.put_state(value)
  end
end

defmodule RetrieveState.Slow do
  def put_state(value) do
    :persistent_term.put(:stored_state, :returned_state)
  end
end

defmodule RetrieveState.Benchmark do
  def benchmark do
    ets_pid = :ets.new(:state_store, [:set, :public])
    StateHolder.start_link()

    Benchee.run(
      %{
        "ets table" => fn -> RetrieveState.Fast.put_state(ets_pid, :returned_value) end,
        "gen server" => fn -> RetrieveState.Medium.put_state(:returned_value) end,
        "persistent term" => fn -> RetrieveState.Slow.put_state(:returned_value) end
      },
      time: 10,
      print: [fast_warning: false]
    )
  end
end

RetrieveState.Benchmark.benchmark()
