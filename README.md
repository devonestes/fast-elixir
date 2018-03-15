# Fast Elixir

There is a wonderful project in Ruby called [fast-ruby](https://github.com/JuanitoFatas/fast-ruby), from which I got the inspiration for this repo. The idea is to collect various idioms for writing performant code when there is more than one _essentially_ symantically identical way of computing something. There may be slight differences, so please be sure that when you're changing something that it doesn't change the correctness of your program.

Each idiom has a corresponding code example that resides in [code](code).

**Let's write faster code, together! <3**

## Measurement Tool

We use [benchee](https://github.com/PragTob/benchee).

## Contributing

Help us collect benchmarks! Please [read the contributing guide](CONTRIBUTING.md).

## Idioms

#### Map Lookup vs. Pattern Matching Lookup [code](code/general/map_lookup_vs_pattern_matching.exs)

If you need to lookup static values in a key-value based structure, you might at
first consider assigning a map as a module attribute and looking that up.
However, it's significantly faster to use pattern matching to define functions
that behave like a key-value based data structure.

```
$ mix run code/general/map_lookup_vs_pattern_matching.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8.589934592 GB
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
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8.589934592 GB
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

#### Combining lists with `|` vs. `++` [code](code/general/concat_vs_cons.exs)

Adding two lists together might seem like a simple problem to solve, but in
Elixir there are a couple ways to solve that issue. We can use `++` to
concatenate two lists easily: `[1, 2] ++ [3, 4] #=> [1, 2, 3, 4]`, but the
problem with that approach is that once you start dealing with larger lists it
becomes **VERY** slow! Because of this, when combining two lists, you should try
and use the cons operator (`|`) whenever possible. This will require you to
remember to flatten the resulting nested list, but it's a huge performance
optimization on larger lists.

```
$ mix run code/general/concat_vs_cons.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8.589934592 GB
Elixir 1.6.0-rc.0
Erlang 20.1.1
Benchmark suite executing with the following configuration:
warmup: 2.00 s
time: 10.00 s
parallel: 1
inputs: Large (30,000 items), Medium (3,000 items), Small (30 items)
Estimated total run time: 1.80 min



Benchmarking with input Large (30,000 items):
Benchmarking Concatenation...
Benchmarking Cons + Flatten...
Benchmarking Cons + Reverse + Flatten...

Benchmarking with input Medium (3,000 items):
Benchmarking Concatenation...
Benchmarking Cons + Flatten...
Benchmarking Cons + Reverse + Flatten...

Benchmarking with input Small (30 items):
Benchmarking Concatenation...
Benchmarking Cons + Flatten...
Benchmarking Cons + Reverse + Flatten...

##### With input Large (30,000 items) #####
Name                               ips        average  deviation         median
Cons + Flatten                  835.02        1.20 ms    ±24.72%        1.09 ms
Cons + Reverse + Flatten        552.54        1.81 ms    ±93.13%        1.41 ms
Concatenation                     1.01      991.80 ms     ±9.67%      942.94 ms

Comparison:
Cons + Flatten                  835.02
Cons + Reverse + Flatten        552.54 - 1.51x slower
Concatenation                     1.01 - 828.18x slower

##### With input Medium (3,000 items) #####
Name                               ips        average  deviation         median
Cons + Flatten                  8.54 K      117.06 μs   ±127.61%       99.00 μs
Cons + Reverse + Flatten        8.51 K      117.51 μs   ±157.46%      101.00 μs
Concatenation                  0.121 K     8286.62 μs    ±21.36%     7957.00 μs

Comparison:
Cons + Flatten                  8.54 K
Cons + Reverse + Flatten        8.51 K - 1.00x slower
Concatenation                  0.121 K - 70.79x slower

##### With input Small (30 items) #####
Name                               ips        average  deviation         median
Cons + Flatten                712.46 K        1.40 μs   ±518.46%        1.10 μs
Cons + Reverse + Flatten      705.14 K        1.42 μs   ±385.13%        1.20 μs
Concatenation                 701.87 K        1.42 μs  ±5519.46%        1.00 μs

Comparison:
Cons + Flatten                712.46 K
Cons + Reverse + Flatten      705.14 K - 1.01x slower
Concatenation                 701.87 K - 1.02x slower
```

#### Splitting Large Strings [code](code/general/string_split_large_strings.exs)

Due to a known issue in Erlang, splitting very large strings can be done faster
using Elixir's streaming approach rather than using `String.split/2`.

```
$ mix run code/general/string_split_large_strings.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8.589934592 GB
Elixir 1.4.2
Erlang 19.2.3
Benchmark suite executing with the following configuration:
warmup: 2.00 s
time: 10.00 s
parallel: 1
inputs: Large string (1 Million Numbers), Medium string (10 Thousand Numbers), Small string (1 Hundred Numbers)
Estimated total run time: 1.20 min

##### With input Large string (1 Million Numbers) #####
Name                          ips        average  deviation         median
splitter |> to_list          0.86         1.16 s    ±10.78%         1.12 s
split                        0.22         4.61 s     ±0.68%         4.61 s

Comparison:
splitter |> to_list          0.86
split                        0.22 - 3.98x slower

##### With input Medium string (10 Thousand Numbers) #####
Name                          ips        average  deviation         median
split                      1.34 K        0.75 ms    ±37.86%        0.66 ms
splitter |> to_list        0.24 K        4.15 ms    ±23.00%        3.90 ms

Comparison:
split                      1.34 K
splitter |> to_list        0.24 K - 5.55x slower

##### With input Small string (1 Hundred Numbers) #####
Name                          ips        average  deviation         median
split                    274.56 K        3.64 μs  ±1094.44%        3.00 μs
splitter |> to_list       31.03 K       32.23 μs    ±71.77%       28.00 μs

Comparison:
split                    274.56 K
splitter |> to_list       31.03 K - 8.85x slower
```

#### `sort` vs. `sort_by` [code](code/general/sort_vs_sort_by.exs)

Sorting a list of maps or keyword lists can be done in various ways,
given that the key-value you want to sort on is the first one defined
in the associative data structure. The speed differences are minimal.

```
↪ mix run code/general/sort_vs_sort_by.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-4558U CPU @ 2.80GHz
Number of Available Cores: 4
Available memory: 17.179869184 GB
Elixir 1.4.4
Erlang 19.3
Benchmark suite executing with the following configuration:
warmup: 2.00 s
time: 10.00 s
parallel: 1
inputs: none specified
Estimated total run time: 36.00 s


Benchmarking sort/1...
Benchmarking sort/2...
Benchmarking sort_by/2...

Name                ips        average  deviation         median
sort/1           5.20 K      192.27 μs    ±18.76%      182.00 μs
sort/2           4.93 K      202.81 μs    ±24.58%      191.00 μs
sort_by/2        4.81 K      207.88 μs    ±17.71%      198.00 μs

Comparison:
sort/1           5.20 K
sort/2           4.93 K - 1.05x slower
sort_by/2        4.81 K - 1.08x slower
```

#### Retrieving state from ets tables vs. Gen Servers [code](code/general/ets_vs_gen_server.exs)

There are many differences between Gen Servers and ets tables, but many people
have often praised ets tables for being extremely fast. For the simple case of
retrieving information from a key-value store, the ets table is indeed much
faster for lookups. For more complicated use cases, and for comparisons of
writes instead of reads, further benchmarks are needed, but so far ets lives up
to its reputation for speed.

```
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8.589934592 GB
Elixir 1.7.0-dev
Erlang 20.2
Benchmark suite executing with the following configuration:
warmup: 2.00 s
time: 10.00 s
parallel: 1
inputs: none specified
Estimated total run time: 24.00 s


Benchmarking ets table...
Benchmarking gen server...

Name                 ips        average  deviation         median
ets table         9.18 M       0.109 μs   ±555.09%       0.100 μs
gen server        0.34 M        2.97 μs  ±1954.50%        3.00 μs

Comparison:
ets table         9.18 M
gen server        0.34 M - 27.24x slower
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
