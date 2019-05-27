# Contributing to fast-elixir

Thank you for contributing! Let's get you started!

## Adding a benchmark

1. Fork and clone the repository

1. Install the Elixir/Erlang versions in [`.tool-versions`](.tool-versions)

1. Install dependencies: `mix deps.get`

1. Write a benchmark using the following template:

    ```elixir
    defmodule IdiomName.Fast do
      def function_name do
      end
    end

    defmodule IdiomName.Slow do
      def function_name do
      end
    end

    defmodule IdiomName.Benchmark do
      def benchmark do
        Benchee.run(%{
          "Idiom Name Fast" => fn -> bench(IdiomName.Fast) end,
          "Idiom Name Slow" => fn -> bench(IdiomName.Slow) end,
        }, time: 10, print: [fast_warning: false])
      end

      defp bench(module) do
        module.function_name
      end
    end

    IdiomName.Benchmark.benchmark()
    ```

1. Run your benchmark: `mix run code/<category>/<benchmark>.exs`

1. Add the output along with a description to the [README](README.md)

1. Open a Pull Request!
