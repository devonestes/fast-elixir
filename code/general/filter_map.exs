defmodule FilterMap.For do
  def filter_map(list, filter_fun, map_fun) do
    for num <- list, filter_fun.(num), do: map_fun.(num)
  end
end

defmodule FilterMap.FilterMap do
  def filter_map(list, filter_fun, map_fun) do
    list
    |> Enum.filter(filter_fun)
    |> Enum.map(map_fun)
  end
end

defmodule FilterMap.FlatMap do
  def filter_map(list, filter_fun, map_fun) do
    Enum.flat_map(list, fn num ->
      if filter_fun.(num) do
        [map_fun.(num)]
      else
        []
      end
    end)
  end
end

defmodule FilterMap.ReduceReverse do
  def filter_map(list, filter_fun, map_fun) do
    list
    |> Enum.reduce([], fn num, acc ->
      if filter_fun.(num) do
        [map_fun.(num) | acc]
      else
        acc
      end
    end)
    |> Enum.reverse()
  end
end

defmodule FilterMap.Benchmark do
  @inputs %{
    "Large" => 1..1_000_000,
    "Medium" => 1..10000,
    "Small" => 1..100
  }

  def benchmark do
    Benchee.run(
      %{
        "for comprehension" => fn range -> bench_func(FilterMap.For, range) end,
        "filter |> map" => fn range -> bench_func(FilterMap.FilterMap, range) end,
        "flat_map" => fn range -> bench_func(FilterMap.FlatMap, range) end,
        "reduce |> reverse" => fn range -> bench_func(FilterMap.ReduceReverse, range) end
      },
      time: 10,
      memory_time: 0.01,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  def bench_func(module, range) do
    module.filter_map(range, &(rem(&1, 3) == 0), &(&1 + 1))
  end
end

FilterMap.Benchmark.benchmark()
