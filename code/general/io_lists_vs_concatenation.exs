defmodule Output.Fast do
  def output(a, b, c, d) do
    space = " "
    IO.puts [[[[[[a | space] | b ] | space] | c] | space] | d]
  end
end

defmodule Output.Slow do
  def output(a, b, c, d) do
    IO.puts "#{a} #{b} #{c} #{d}"
  end
end

defmodule Output.Benchmark do
  def benchmark do
    Benchee.run(%{
      "IO List"       => fn -> bench_func(Output.Fast) end,
      "Interpolation" => fn -> bench_func(Output.Slow) end
    }, time: 10, print: [fast_warning: false])
  end

  def bench_func(module) do
    module.output("a", "b", "c", "d")
    module.output("e", "f", "g", "h")
    module.output("All of", "the words", "that I know", "are here.")
    module.output("All of", "the words", "that I know", ["are ", "a", "b", "c"])
  end
end

Output.Benchmark.benchmark()
