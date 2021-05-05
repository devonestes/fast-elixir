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
  @small_list Enum.to_list(1..10)
  @large_list Enum.to_list(1..1_000)

  @inputs %{
    "1,000 small items" => {1..1_000, @small_list},
    "100 small items" => {1..100, @small_list},
    "10 small items" => {1..10, @small_list},
    "1,000 large items" => {1..1_000, @large_list},
    "100 large items" => {1..100, @large_list},
    "10 large items" => {1..10, @large_list},
  }

  def benchmark do
    Benchee.run(
      %{
        "Cons + Flatten" => fn enumerator -> bench_func(enumerator, ListAdd.Fast) end,
        "Cons + Reverse + Flatten" => fn enumerator -> bench_func(enumerator, ListAdd.Medium) end,
        "Concatenation" => fn enumerator -> bench_func(enumerator, ListAdd.Slow) end
      },
      time: 10,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  def bench_func({enumerator, list}, module) do
    module.add_lists(enumerator, list)
  end
end

# Enum.each([ListAdd.Slow, ListAdd.Medium, ListAdd.Fast], fn module ->
# IO.inspect(
# [0, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3] == module.add_lists(0..4, [1, 2, 3])
# )
# end)

ListAdd.Benchmark.benchmark()
