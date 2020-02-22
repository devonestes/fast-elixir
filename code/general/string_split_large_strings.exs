defmodule Split.Fast do
  def split(str) do
    str |> String.splitter(",") |> Enum.to_list
  end
end

defmodule Split.Slow do
  def split(str) do
    String.split(str, ",")
  end
end

defmodule Split.Regex do
  def split(str) do
    String.split(str, ~r/,/)
  end
end

defmodule Split.Erlang do
  def split(str) do
    :string.split(str, ",", :all)
  end
end


defmodule Split.Benchmark do
  @inputs %{
    "Large string (1 Million Numbers)"    => Enum.join((1..1_000_000), ","),
    "Medium string (10 Thousand Numbers)" => Enum.join((1..10_000), ","),
    "Small string (1 Hundred Numbers)"    => Enum.join((1..100), ",")
  }

  def benchmark do
    Benchee.run(%{
      "splitter |> to_list" => fn(str) -> bench_func(Split.Fast, str) end,
      "split"               => fn(str) -> bench_func(Split.Slow, str) end,
      "split regex"         => fn(str) -> bench_func(Split.Regex, str) end,
      "split erlang"        => fn(str) -> bench_func(Split.Erlang, str) end
    }, time: 10, inputs: @inputs, print: [fast_warning: false])
  end

  def bench_func(module, str) do
    module.split(str)
  end
end

Split.Benchmark.benchmark()
