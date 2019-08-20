defmodule Random.Slow do
  def get_random_number(max) do
    Enum.random(1..max)
  end
end

defmodule Random.Fast do
  def get_random_number(max) do
    :rand.uniform(max)
  end
end

defmodule Random.Benchmark do
  def benchmark do
    Benchee.run(%{
      ":rand.uniform/1 (Fast)" => fn max -> bench(Random.Fast, max) end,
      "Enum.random/1 (Slow)" => fn max -> bench(Random.Slow, max) end
    },
    time: 10,
    inputs: %{
      "Minimal" => 10,
      "Small" => 1_000,
      "Medium" => 10_000,
      "Bigger" => 100_000
    },
    print: [fast_warning: false])
  end

  def bench(module, max) do
    module.get_random_number(max)
  end
end

Random.Benchmark.benchmark()
