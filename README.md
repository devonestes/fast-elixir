Fast Elixir 
=======================================================================================================================================================================

There is a wonderful project in Ruby called [fast-ruby](https://github.com/JuanitoFatas/fast-ruby), from which I got the inspiration for this repo. The idea is to collect various idioms for writing performant code when there is more than one _essentially_ symantically identical way of computing something. There may be slight differences, so please be sure that when you're changing something that it doesn't change the correctness of your program.

Each idiom has a corresponding code example that resides in [code](code).

All results listed in README.md are running with:
* Elixir 1.4.2
* Erlang/OTP 19 [erts-8.2.2] [source] [64-bit] [smp:4:4] [async-threads:10] [hipe] [kernel-poll:false] [dtrace].

Machine information: MacBook Air (13-inch, Early 2014), 1.4 GHz Intel Core i5, 8 GB 1600 MHz DDR3, running MacOS Sierra 10.12.4. Your results may vary, but you get the idea. :)

**Let's write faster code, together! <3**

Measurement Tool
-----------------

Use [benchee](https://github.com/PragTob/benchee) (0.7+).

### Template

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
      "Idiom Name Fast" => fn -> bench_func(IdiomName.Fast) end,
      "Idiom Name Slow" => fn -> bench_func(IdiomName.Slow) end
    }, time: 10, print: [fast_warning: false])
  end

  def bench_func(module) do
    module.function_name
  end
end

IdiomName.Benchmark.benchmark()
```

Idioms
------

#### Map Lookup vs. Pattern Matching Lookup [code](code/general/map_lookup_vs_pattern_matching.exs)

If you need to lookup static values in a key-value based structure, you might at
first consider assigning a map as a module attribute and looking that up.
However, it's significantly faster to use pattern matching to define functions
that behave like a key-value based data structure.

```
$ mix run code/general/map_lookup_vs_pattern_matching.exs
Elixir 1.4.2
Erlang 19.2.3
Benchmark suite executing with the following configuration:
warmup: 2.0s
time: 10.0s
parallel: 1
inputs: none specified
Estimated total run time: 24.0s

Benchmarking Map Lookup...
Benchmarking Pattern Matching...

Name                       ips        average  deviation         median
Pattern Matching      726.52 K        1.38 μs   ±376.42%        1.20 μs
Map Lookup            455.62 K        2.19 μs   ±185.63%        1.90 μs

Comparison:
Pattern Matching      726.52 K
Map Lookup            455.62 K - 1.59x slower
```

#### IO Lists vs. String Concatenation [code](code/general/io_lists_vs_concatenation.exs)

Chances are, eventually you'll need to concatenate strings for some sort of
output. This could be in a web response, a CLI output, or writing to a file. The
faster way to do this is to use IO Lists rather than string concatenation or
interpolation.

```
$ mix run code/general/io_lists_vs_concatenation.exs
Elixir 1.4.2
Erlang 19.2.3
Benchmark suite executing with the following configuration:
warmup: 2.0s
time: 10.0s
parallel: 1
inputs: none specified
Estimated total run time: 24.0s

Benchmarking IO List...
Benchmarking Interpolation...

Name                    ips        average  deviation         median
IO List             27.12 K       36.87 μs   ±345.26%       33.00 μs
Interpolation       18.92 K       52.84 μs   ±567.23%       36.00 μs

Comparison:
IO List             27.12 K
Interpolation       18.92 K - 1.43x slower
```

## Something went wrong

Something look wrong to you? :cry: Have a better example? :heart_eyes: Excellent!

[Please open an Issue](https://github.com/devonestes/fast-elixir/issues/new) or [open a Pull Request](https://github.com/devonestes/fast-elixir/pulls) to fix it.

Thank you in advance! :wink: :beer:


## Also Checkout

- [Benchmarking in Practice](https://www.youtube.com/watch?v=7-mE5CKXjkw)

  Talk by [@PragTob](https://github.com/PragTob) from ElixirLive 2016 about benchmarking in Elixir.

- [Credo](https://github.com/rrrene/credo)

  Wonderful static analysis tool by [@rrrene](https://github.com/rrrene). It's not _just_ about speed, but it will flag some performance issues.



Brought to you by [@devoncestes](https://twitter.com/devoncestes)

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).


## Code License

### CC0 1.0 Universal

To the extent possible under law, @devonestes has waived all copyright and related or neighboring rights to "fast-elixir".

This work belongs to the community.
