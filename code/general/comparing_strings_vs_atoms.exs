defmodule Compare.Fast do
  def compare(first, second) do
    first == second
  end
end

defmodule Compare.Medium do
  def compare(first, second) do
    String.to_atom(first) == String.to_atom(second)
  end
end

defmodule Compare.Slow do
  def compare(first, second) do
    first == second
  end
end

defmodule Compare.Benchmark do
  @inputs %{
    "Large (1-100)" => :large,
    "Medium (1-50)" => :medium,
    "Small (1-5)" => :small
  }

  @strings_right %{
    large: Enum.join(1..100),
    medium: Enum.join(1..50),
    small: Enum.join(1..5)
  }

  @strings_left %{
    large: Enum.join(2..101),
    medium: Enum.join(2..51),
    small: Enum.join(2..6)
  }

  @atoms_right %{
    large: 1..100 |> Enum.join |> String.to_atom,
    medium: 1..50 |> Enum.join |> String.to_atom,
    small: 1..5 |> Enum.join |> String.to_atom
  }

  @atoms_left %{
    large: 2..101 |> Enum.join |> String.to_atom,
    medium: 2..51 |> Enum.join |> String.to_atom,
    small: 2..6 |> Enum.join |> String.to_atom
  }

  def benchmark do
    Benchee.run(
      %{
        "Comparing atoms" => fn key -> bench_func(@atoms_left[key], @atoms_right[key], Compare.Fast) end,
        "Converting to atoms and then comparing" => fn key -> bench_func(@strings_left[key], @strings_right[key], Compare.Medium) end,
        "Comparing strings" => fn key -> bench_func(@strings_left[key], @strings_right[key], Compare.Slow) end
      },
      time: 10,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  def bench_func(first, second, module) do
    module.compare(first, second)
  end
end

Compare.Benchmark.benchmark()
