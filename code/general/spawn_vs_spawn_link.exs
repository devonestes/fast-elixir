defmodule Spawn.Benchmark do
  def benchmark do
    Benchee.run(
      %{
        "spawn/1" => fn -> bench(&spawn/1) end,
        "spawn_link/1" => fn -> bench(&spawn_link/1) end
      },
      time: 10,
      memory_time: 2,
      print: [fast_warning: false]
    )
  end

  defp bench(fun) do
    me = self()
    fun.(fn -> send(me, nil) end)

    receive do
      nil -> nil
    end
  end
end

Spawn.Benchmark.benchmark()
