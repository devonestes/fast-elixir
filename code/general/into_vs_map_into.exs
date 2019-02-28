defmodule Into.Benchmark do
  @inputs %{
    "Large (30k)" => 0..30_000,
    "Medium (3k)" => 0..3000,
    "Small (30)" => 0..30
  }

  def benchmark do
    fun = fn num -> {num, num} end
    Benchee.run(
      %{
        "Enum.into/3" => fn input -> Enum.into(input, %{}, fun) end,
        "Enum.map/2 |> Enum.into/2" => fn input -> input |> Enum.map(fun) |> Enum.into(%{}) end,
        "for |> into" => fn input -> for num <- input, into: %{}, do: {num, num} end
      },
      time: 10,
      memory_time: 0.1,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end
end

Into.Benchmark.benchmark()
