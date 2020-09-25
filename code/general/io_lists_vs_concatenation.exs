# To make this a fair test and to use varying numbers of arguments as inputs, I needed to write
# the actual modules in a very macro-heavy way. Both of these modules are essentially doing the
# following:
#
# defmodule Output.Fast do
#   def output(a, b, c, d, e) do
#     [e | [d | [c | [a | b]]]]
#   end
#
#   # and so on for the 50 and 100 argument versions of that function.
# end
#
# defmodule Output.Slow do
#   def output(a, b, c, d, e) do
#     "#{e}#{d}#{c}#{a}#{e}"
#   end
#
#   # and so on for the 50 and 100 argument versions of that function.
# end

defmodule Output.Fast do
  Enum.each([5, 50, 100], fn count ->
    [first, second | rest] = vars = Macro.generate_arguments(count, __MODULE__)

    starting =
      quote do
        [unquote(first) | unquote(second)]
      end

    cons_expr =
      Enum.reduce(rest, starting, fn var, acc ->
        quote do
          [unquote(var) | unquote(acc)]
        end
      end)

    def output(unquote_splicing(vars)) do
      unquote(cons_expr)
    end
  end)
end

defmodule Output.Slow do
  Enum.each([5, 50, 100], fn count ->
    [first | rest] = vars = Macro.generate_arguments(count, __MODULE__)

    starting = [
      {:"::", [], [{{:., [], [Kernel, :to_string]}, [], [first]}, {:binary, [], Output.Slow}]}
    ]

    interpolation_expr =
      Enum.reduce(rest, starting, fn var, acc ->
        [
          {:"::", [], [{{:., [], [Kernel, :to_string]}, [], [var]}, {:binary, [], Output.Slow}]}
          | acc
        ]
      end)

    def output(unquote_splicing(vars)) do
      unquote({:<<>>, [], interpolation_expr})
    end
  end)
end

defmodule Output.Benchmark do
  def inputs do
    %{
      "100 3-character strings" => generate_chunks(3, 100),
      "100 300-character strings" => generate_chunks(300, 100),
      "50 3-character strings" => generate_chunks(3, 50),
      "50 300-character strings" => generate_chunks(300, 50),
      "5 3-character_strings" => generate_chunks(3, 5),
      "5 300-character_strings" => generate_chunks(300, 5)
    }
  end

  def generate_chunks(chunk_size, count) do
      ?a..?z
      |> Stream.cycle()
      |> Stream.chunk_every(chunk_size)
      |> Stream.map(&to_string/1)
      |> Enum.take(count)
  end

  def benchmark do
    Benchee.run(
      %{
        "IO List" => fn input -> apply(Output.Fast, :output, input) end,
        "Interpolation" => fn input -> apply(Output.Slow, :output, input) end
      },
      inputs: inputs(),
      time: 10,
      print: [fast_warning: false]
    )
  end
end

Output.Benchmark.benchmark()
