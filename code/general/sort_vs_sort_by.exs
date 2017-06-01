defmodule Card, do: defstruct [:rank, :suit]

defmodule Sort.Fast do
  def sort(enumerable), do: Enum.sort(enumerable)
end

defmodule Sort.Slow do
  def sort(enumerable), do: Enum.sort(enumerable, &(&1.rank) <= (&2.rank))
end

defmodule Sort.Slowest do
  def sort(enumerable), do: Enum.sort_by(enumerable, &(&1.rank))
end

defmodule Sort.Benchmark do
  def benchmark do
    Benchee.run(%{
      "sort/1" => fn -> bench(Sort.Fast) end,
      "sort/2" => fn -> bench(Sort.Slow) end,
      "sort_by/2" => fn -> bench(Sort.Slowest) end,
    }, time: 10, print: [fast_warning: false])
  end

  defp bench(module) do
    cards = Enum.map 1..100, fn _ ->
      %Card{rank: Enum.random(0..100), suit: Enum.random(~w[red green blue]a)}
    end

    module.sort(cards)
  end
end

Sort.Benchmark.benchmark()
