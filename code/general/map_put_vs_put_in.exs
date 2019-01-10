defmodule MapPut.Fast do
  def map_put(enumerator, map) do
    enumerator
    |> Enum.reduce(map, fn value, acc ->
      Map.put(acc, value, value)
    end)
  end
end

defmodule MapPut.Slower do
  def map_put(enumerator, map) do
    enumerator
    |> Enum.reduce(map, fn value, acc ->
      put_in(acc[value], value)
    end)
  end
end

defmodule MapPut.Slowest do
  def map_put(enumerator, map) do
    enumerator
    |> Enum.reduce(map, fn value, acc ->
      put_in(acc, [value], value)
    end)
  end
end

defmodule MapPut.Benchmark do
  @inputs %{
    "Large (30,000 items)" => 1..10_000,
    "Medium (3,000 items)" => 1..1_000,
    "Small (30 items)" => 1..10
  }

  def benchmark do
    Benchee.run(
      %{
        "Map.put/3" => fn enumerator -> bench_func(enumerator, MapPut.Fast) end,
        "put_in/2" => fn enumerator -> bench_func(enumerator, MapPut.Slower) end,
        "put_in/3" => fn enumerator -> bench_func(enumerator, MapPut.Slowest) end
      },
      time: 10,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  @map %{
    a: 1,
    b: 2,
    c: 3
  }

  def bench_func(enumerator, module) do
    module.map_put(enumerator, @map)
  end
end

MapPut.Benchmark.benchmark()
