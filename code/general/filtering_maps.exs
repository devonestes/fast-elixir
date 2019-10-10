defmodule FilterMap.EnumFilterMapNew do
  def filter(map, func) do
    map
    |> Enum.filter(func)
    |> Map.new()
  end
end

defmodule FilterMap.EnumFilterEnumInto do
  def filter(map, func) do
    map
    |> Enum.filter(func)
    |> Enum.into(%{})
  end
end

defmodule FilterMap.For do
  def filter(map, func) do
    for tuple <- map, func.(tuple), into: %{}, do: tuple
  end
end

defmodule FilterMap.MapsFilter do
  def filter(map, func) do
    :maps.filter(func, map)
  end
end

defmodule Compare.Benchmark do
  @inputs %{
    "Large (10_000)" => 1..10_000 |> Enum.map(&{&1, &1+1}) |> Map.new(),
    "Medium (100)" => 1..100 |> Enum.map(&{&1, &1+1}) |> Map.new(),
    "Small (1)" => %{1 => 2}
  }

  def func({key, value}) do
    key != value
  end

  def func(key, value) do
    key != value
  end

  def benchmark do
    Benchee.run(
      %{
        "Enum.filter/2 |> Map.new/1" => fn map -> bench_func(FilterMap.EnumFilterMapNew, map, &func/1) end,
        "Enum.filter/2 |> Enum.into/2" => fn map -> bench_func(FilterMap.EnumFilterEnumInto, map, &func/1) end,
        "for" => fn map -> bench_func(FilterMap.For, map, &func/1) end,
        ":maps.filter" => fn map -> bench_func(FilterMap.MapsFilter, map, &func/2) end
      },
      time: 10,
      memory_time: 1,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  def bench_func(module, map, func) do
    module.filter(map, func)
  end
end

Compare.Benchmark.benchmark()
