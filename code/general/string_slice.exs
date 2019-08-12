defmodule StringSlice.Benchmark do
  @inputs %{
    "Large string (10 Thousand Numbers)" => Enum.join(1..10_000, ","),
    "Small string (10 Numbers)" => Enum.join(1..10, ",")
  }

  def benchmark do
    Benchee.run(
      %{
        "String.slice/3" => fn string -> string |> String.slice(3, 5) end,
        "binary_part/3" => fn string -> string |> binary_part(3, 5) end,
        ":binary.part/3" => fn string -> string |> :binary.part(3, 5) end
      },
      warmup: 0.1,
      time: 2,
      memory_time: 0.01,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end
end

StringSlice.Benchmark.benchmark()
