defmodule ListAdd.Fast do
  def add_lists(enumerator, list) do
    enumerator
    |> Enum.reduce([0], fn _, acc ->
      [acc | list]
    end)
    |> List.flatten()
  end
end

defmodule ListAdd.Medium do
  def add_lists(enumerator, list) do
    enumerator
    |> Enum.reduce([0], fn _, acc ->
      [list | acc]
    end)
    |> Enum.reverse()
    |> List.flatten()
  end
end

defmodule ListAdd.Slow do
  def add_lists(enumerator, list) do
    Enum.reduce(enumerator, [0], fn _, acc ->
      acc ++ list
    end)
  end
end

defmodule ListAdd.Benchmark do
  @inputs %{
    "Large (30,000 items)" => 1..10_000,
    "Medium (3,000 items)" => 1..1_000,
    "Small (30 items)" => 1..10
  }

  def benchmark do
    Benchee.run(
      %{
        "Cons + Flatten"           => fn enumerator -> bench_func(enumerator, ListAdd.Fast) end,
        "Cons + Reverse + Flatten" => fn enumerator -> bench_func(enumerator, ListAdd.Medium) end,
        "Concatenation"            => fn enumerator -> bench_func(enumerator, ListAdd.Slow) end
      },
      time: 10,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  @list [1, 2, 3]

  def bench_func(enumerator, module) do
    module.add_lists(enumerator, @list)
  end
end

#expected = [0, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3]
#IO.inspect(ListAdd.Fast.add_lists(0..4, [1, 2, 3]) == expected)
#IO.inspect(ListAdd.Slow.add_lists(0..4, [1, 2, 3]) == expected)
#IO.inspect(ListAdd.Medium.add_lists(0..4, [1, 2, 3]) == expected)

ListAdd.Benchmark.benchmark()
