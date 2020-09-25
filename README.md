# Fast Elixir

There is a wonderful project in Ruby called [fast-ruby](https://github.com/JuanitoFatas/fast-ruby), from which I got the inspiration for this repo. The idea is to collect various idioms for writing performant code when there is more than one _essentially_ symantically identical way of computing something. There may be slight differences, so please be sure that when you're changing something that it doesn't change the correctness of your program.

Each idiom has a corresponding code example that resides in [code](code).

**Let's write faster code, together! <3**

## Measurement Tool

We use [benchee](https://github.com/PragTob/benchee).

## Contributing

Help us collect benchmarks! Please [read the contributing guide](CONTRIBUTING.md).

## Idioms

- [Map Lookup vs. Pattern Matching Lookup](#map-lookup-vs-pattern-matching-lookup-code)
- [IO Lists vs. String Concatenation](#io-lists-vs-string-concatenation-code)
- [Combining lists with `|` vs. `++`](#combining-lists-with--vs--code)
- [Putting into maps with `Map.put` and `put_in`](#putting-into-maps-with-mapput-and-put_in-code)
- [Splitting Strings](#splitting-large-strings-code)
- [`sort` vs. `sort_by`](#sort-vs-sort_by-code)
- [Retrieving state from ets tables vs. Gen Servers](#retrieving-state-from-ets-tables-vs-gen-servers-code)
- [Comparing strings vs. atoms](#comparing-strings-vs-atoms-code)
- [spawn vs. spawn_link](#spawn-vs-spawn_link-code)
- [Replacements for Enum.filter_map/3](#replacements-for-enumfilter_map3-code)
- [Filtering maps](#filtering-maps-code)

#### Map Lookup vs. Pattern Matching Lookup [code](code/general/map_lookup_vs_pattern_matching.exs)

If you need to lookup static values in a key-value based structure, you might at
first consider assigning a map as a module attribute and looking that up.
However, it's significantly faster to use pattern matching to define functions
that behave like a key-value based data structure.

```
$ mix run code/general/map_lookup_vs_pattern_matching.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 24 s

Benchmarking Map Lookup...
Benchmarking Pattern Matching...

Name                       ips        average  deviation         median         99th %
Pattern Matching      909.12 K        1.10 μs  ±3606.70%           1 μs           2 μs
Map Lookup            792.96 K        1.26 μs   ±532.10%           1 μs           2 μs

Comparison:
Pattern Matching      909.12 K
Map Lookup            792.96 K - 1.15x slower +0.161 μs
```

#### IO Lists vs. String Concatenation [code](code/general/io_lists_vs_concatenation.exs)

Chances are, eventually you'll need to concatenate strings for some sort of
output. This could be in a web response, a CLI output, or writing to a file. The
faster way to do this is to use IO Lists rather than string concatenation or
interpolation.

```
$ mix run code/general/io_lists_vs_concatenation.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: 100 3-character strings, 100 300-character strings, 5 3-character_strings, 5 300-character_strings, 50 3-character strings, 50 300-character strings
Estimated total run time: 2.40 min

Benchmarking IO List with input 100 3-character strings...
Benchmarking IO List with input 100 300-character strings...
Benchmarking IO List with input 5 3-character_strings...
Benchmarking IO List with input 5 300-character_strings...
Benchmarking IO List with input 50 3-character strings...
Benchmarking IO List with input 50 300-character strings...
Benchmarking Interpolation with input 100 3-character strings...
Benchmarking Interpolation with input 100 300-character strings...
Benchmarking Interpolation with input 5 3-character_strings...
Benchmarking Interpolation with input 5 300-character_strings...
Benchmarking Interpolation with input 50 3-character strings...
Benchmarking Interpolation with input 50 300-character strings...

##### With input 100 3-character strings #####
Name                    ips        average  deviation         median         99th %
IO List              1.41 M        0.71 μs  ±4475.40%           1 μs           2 μs
Interpolation        0.31 M        3.27 μs    ±76.91%           3 μs          11 μs

Comparison:
IO List              1.41 M
Interpolation        0.31 M - 4.61x slower +2.56 μs

##### With input 100 300-character strings #####
Name                    ips        average  deviation         median         99th %
IO List              1.40 M        0.71 μs  ±4411.36%           1 μs           1 μs
Interpolation        0.20 M        4.90 μs   ±248.22%           4 μs          22 μs

Comparison:
IO List              1.40 M
Interpolation        0.20 M - 6.86x slower +4.18 μs

##### With input 5 3-character_strings #####
Name                    ips        average  deviation         median         99th %
IO List              5.15 M      194.15 ns  ±2555.27%           0 ns        1000 ns
Interpolation        1.84 M      544.12 ns  ±4764.73%           0 ns        2000 ns

Comparison:
IO List              5.15 M
Interpolation        1.84 M - 2.80x slower +349.96 ns

##### With input 5 300-character_strings #####
Name                    ips        average  deviation         median         99th %
IO List              5.03 M      198.76 ns  ±4663.45%           0 ns        1000 ns
Interpolation        1.92 M      521.81 ns   ±193.09%           0 ns        1000 ns

Comparison:
IO List              5.03 M
Interpolation        1.92 M - 2.63x slower +323.05 ns

##### With input 50 3-character strings #####
Name                    ips        average  deviation         median         99th %
IO List              1.94 M        0.52 μs  ±6397.19%           0 μs           2 μs
Interpolation        0.57 M        1.75 μs   ±130.98%           2 μs           2 μs

Comparison:
IO List              1.94 M
Interpolation        0.57 M - 3.40x slower +1.24 μs

##### With input 50 300-character strings #####
Name                    ips        average  deviation         median         99th %
IO List              2.06 M        0.49 μs  ±8825.39%           0 μs           2 μs
Interpolation        0.37 M        2.71 μs   ±657.41%           2 μs          14 μs

Comparison:
IO List              2.06 M
Interpolation        0.37 M - 5.58x slower +2.22 μs
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
$ mix run ./code/general/concat_vs_cons.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: 1,000 large items, 1,000 small items, 10 large items, 10 small items, 100 large items, 100 small items
Estimated total run time: 3.60 min

Benchmarking Concatenation with input 1,000 large items...
Benchmarking Concatenation with input 1,000 small items...
Benchmarking Concatenation with input 10 large items...
Benchmarking Concatenation with input 10 small items...
Benchmarking Concatenation with input 100 large items...
Benchmarking Concatenation with input 100 small items...
Benchmarking Cons + Flatten with input 1,000 large items...
Benchmarking Cons + Flatten with input 1,000 small items...
Benchmarking Cons + Flatten with input 10 large items...
Benchmarking Cons + Flatten with input 10 small items...
Benchmarking Cons + Flatten with input 100 large items...
Benchmarking Cons + Flatten with input 100 small items...
Benchmarking Cons + Reverse + Flatten with input 1,000 large items...
Benchmarking Cons + Reverse + Flatten with input 1,000 small items...
Benchmarking Cons + Reverse + Flatten with input 10 large items...
Benchmarking Cons + Reverse + Flatten with input 10 small items...
Benchmarking Cons + Reverse + Flatten with input 100 large items...
Benchmarking Cons + Reverse + Flatten with input 100 small items...

##### With input 1,000 large items #####
Name                               ips        average  deviation         median         99th %
Cons + Reverse + Flatten         38.45       26.01 ms     ±6.11%       25.91 ms       30.56 ms
Cons + Flatten                   38.38       26.06 ms     ±6.39%       26.06 ms       29.32 ms
Concatenation                    0.179     5573.57 ms     ±0.26%     5573.57 ms     5583.94 ms

Comparison:
Cons + Reverse + Flatten         38.45
Cons + Flatten                   38.38 - 1.00x slower +0.0501 ms
Concatenation                    0.179 - 214.32x slower +5547.56 ms

##### With input 1,000 small items #####
Name                               ips        average  deviation         median         99th %
Cons + Reverse + Flatten        3.78 K      264.27 μs    ±19.49%         243 μs         496 μs
Cons + Flatten                  3.76 K      266.16 μs    ±18.53%         246 μs      491.83 μs
Concatenation                 0.0626 K    15984.51 μs     ±8.58%       15927 μs    20412.82 μs

Comparison:
Cons + Reverse + Flatten        3.78 K
Cons + Flatten                  3.76 K - 1.01x slower +1.90 μs
Concatenation                 0.0626 K - 60.49x slower +15720.24 μs

##### With input 10 large items #####
Name                               ips        average  deviation         median         99th %
Concatenation                   8.33 K      120.04 μs    ±31.79%         111 μs         268 μs
Cons + Flatten                  5.12 K      195.17 μs    ±20.09%         181 μs         378 μs
Cons + Reverse + Flatten        5.11 K      195.88 μs    ±20.32%         181 μs         378 μs

Comparison:
Concatenation                   8.33 K
Cons + Flatten                  5.12 K - 1.63x slower +75.13 μs
Cons + Reverse + Flatten        5.11 K - 1.63x slower +75.85 μs

##### With input 10 small items #####
Name                               ips        average  deviation         median         99th %
Concatenation                 575.41 K        1.74 μs  ±1951.31%           1 μs           4 μs
Cons + Flatten                331.62 K        3.02 μs   ±972.07%           3 μs           7 μs
Cons + Reverse + Flatten      330.05 K        3.03 μs   ±853.79%           3 μs           8 μs

Comparison:
Concatenation                 575.41 K
Cons + Flatten                331.62 K - 1.74x slower +1.28 μs
Cons + Reverse + Flatten      330.05 K - 1.74x slower +1.29 μs

##### With input 100 large items #####
Name                               ips        average  deviation         median         99th %
Cons + Reverse + Flatten         38.56       25.93 ms     ±6.25%       25.85 ms       32.02 ms
Cons + Flatten                   38.35       26.08 ms     ±6.30%       26.04 ms       30.68 ms
Concatenation                    0.180     5561.40 ms     ±0.41%     5561.40 ms     5577.71 ms

Comparison:
Cons + Reverse + Flatten         38.56
Cons + Flatten                   38.35 - 1.01x slower +0.145 ms
Concatenation                    0.180 - 214.47x slower +5535.47 ms

##### With input 100 small items #####
Name                               ips        average  deviation         median         99th %
Cons + Flatten                 38.68 K       25.85 μs    ±32.87%          24 μs          69 μs
Cons + Reverse + Flatten       38.23 K       26.16 μs    ±39.65%          24 μs          70 μs
Concatenation                   4.33 K      230.99 μs    ±50.47%         213 μs      590.06 μs

Comparison:
Cons + Flatten                 38.68 K
Cons + Reverse + Flatten       38.23 K - 1.01x slower +0.31 μs
Concatenation                   4.33 K - 8.94x slower +205.13 μs
```

#### Putting into maps with `Map.put` and `put_in` [code](code/general/map_put_vs_put_in.exs)

Do not put data into root of map with `put_in`. It is ~2x slower than `Map.put`. Also `put_in/2`
is more effective than `put_in/3`.

```
$ mix run ./code/general/map_put_vs_put_in.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: Large (30,000 items), Medium (3,000 items), Small (30 items)
Estimated total run time: 1.80 min

Benchmarking Map.put/3 with input Large (30,000 items)...
Benchmarking Map.put/3 with input Medium (3,000 items)...
Benchmarking Map.put/3 with input Small (30 items)...
Benchmarking put_in/2 with input Large (30,000 items)...
Benchmarking put_in/2 with input Medium (3,000 items)...
Benchmarking put_in/2 with input Small (30 items)...
Benchmarking put_in/3 with input Large (30,000 items)...
Benchmarking put_in/3 with input Medium (3,000 items)...
Benchmarking put_in/3 with input Small (30 items)...

##### With input Large (30,000 items) #####
Name                ips        average  deviation         median         99th %
Map.put/3        247.43        4.04 ms    ±10.45%        3.97 ms        5.41 ms
put_in/2         242.10        4.13 ms    ±12.48%        4.01 ms        5.74 ms
put_in/3         221.53        4.51 ms    ±11.11%        4.41 ms        6.13 ms

Comparison:
Map.put/3        247.43
put_in/2         242.10 - 1.02x slower +0.0888 ms
put_in/3         221.53 - 1.12x slower +0.47 ms

##### With input Medium (3,000 items) #####
Name                ips        average  deviation         median         99th %
Map.put/3        5.68 K      175.98 μs    ±34.49%      150.98 μs      400.98 μs
put_in/2         3.62 K      276.42 μs    ±23.76%      252.98 μs      546.98 μs
put_in/3         3.09 K      323.22 μs    ±22.44%      296.98 μs      630.98 μs

Comparison:
Map.put/3        5.68 K
put_in/2         3.62 K - 1.57x slower +100.44 μs
put_in/3         3.09 K - 1.84x slower +147.23 μs

##### With input Small (30 items) #####
Name                ips        average  deviation         median         99th %
Map.put/3     1040.86 K        0.96 μs  ±3795.74%        0.98 μs        1.98 μs
put_in/2       400.53 K        2.50 μs  ±1295.21%        1.98 μs        2.98 μs
put_in/3       338.63 K        2.95 μs  ±1124.35%        1.98 μs        3.98 μs

Comparison:
Map.put/3     1040.86 K
put_in/2       400.53 K - 2.60x slower +1.54 μs
put_in/3       338.63 K - 3.07x slower +1.99 μs
```

#### Splitting Large Strings [code](code/general/string_split_large_strings.exs)

Elixir's `String.split/2` is the fastest option for splitting strings by far, but
using a String literal as the splitter instead of a regex will yield significant
performance benefits.

```
$ mix run code/general/string_split_large_strings.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: Large string (1 Million Numbers), Medium string (10 Thousand Numbers), Small string (1 Hundred Numbers)
Estimated total run time: 2.40 min

Benchmarking split with input Large string (1 Million Numbers)...
Benchmarking split with input Medium string (10 Thousand Numbers)...
Benchmarking split with input Small string (1 Hundred Numbers)...
Benchmarking split erlang with input Large string (1 Million Numbers)...
Benchmarking split erlang with input Medium string (10 Thousand Numbers)...
Benchmarking split erlang with input Small string (1 Hundred Numbers)...
Benchmarking split regex with input Large string (1 Million Numbers)...
Benchmarking split regex with input Medium string (10 Thousand Numbers)...
Benchmarking split regex with input Small string (1 Hundred Numbers)...
Benchmarking splitter |> to_list with input Large string (1 Million Numbers)...
Benchmarking splitter |> to_list with input Medium string (10 Thousand Numbers)...
Benchmarking splitter |> to_list with input Small string (1 Hundred Numbers)...

##### With input Large string (1 Million Numbers) #####
Name                          ips        average  deviation         median         99th %
split                       13.96       71.63 ms    ±29.57%       59.81 ms      121.28 ms
splitter |> to_list          3.24      308.26 ms    ±14.54%      290.97 ms      442.09 ms
split erlang                 1.09      919.28 ms     ±4.86%      939.75 ms      998.24 ms
split regex                  0.78     1286.40 ms     ±9.80%     1253.48 ms     1489.63 ms

Comparison:
split                       13.96
splitter |> to_list          3.24 - 4.30x slower +236.62 ms
split erlang                 1.09 - 12.83x slower +847.65 ms
split regex                  0.78 - 17.96x slower +1214.77 ms

##### With input Medium string (10 Thousand Numbers) #####
Name                          ips        average  deviation         median         99th %
split                     3813.15        0.26 ms    ±45.13%        0.21 ms        0.57 ms
splitter |> to_list        397.04        2.52 ms    ±14.65%        2.48 ms        3.73 ms
split erlang               137.55        7.27 ms     ±8.52%        7.17 ms        9.35 ms
split regex                 93.73       10.67 ms     ±7.46%       10.56 ms       13.07 ms

Comparison:
split                     3813.15
splitter |> to_list        397.04 - 9.60x slower +2.26 ms
split erlang               137.55 - 27.72x slower +7.01 ms
split regex                 93.73 - 40.68x slower +10.41 ms

##### With input Small string (1 Hundred Numbers) #####
Name                          ips        average  deviation         median         99th %
split                    365.94 K        2.73 μs   ±634.81%           2 μs          14 μs
splitter |> to_list       45.63 K       21.92 μs    ±45.25%          20 μs          63 μs
split erlang              14.19 K       70.48 μs    ±48.03%          53 μs      186.91 μs
split regex                9.87 K      101.28 μs    ±24.68%          93 μs         222 μs

Comparison:
split                    365.94 K
splitter |> to_list       45.63 K - 8.02x slower +19.18 μs
split erlang              14.19 K - 25.79x slower +67.74 μs
split regex                9.87 K - 37.06x slower +98.55 μs
```

#### `sort` vs. `sort_by` [code](code/general/sort_vs_sort_by.exs)

Sorting a list of maps or keyword lists can be done in various ways. However, since the sort
behavior is fairly implicit if you're sorting without a defined sort function, and since the
speed difference is quite small, it's probably best to use `sort/2` or `sort_by/2` in all
cases when sorting lists and maps (including keyword lists and structs).

```
$ mix run code/general/sort_vs_sort_by.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 36 s

Benchmarking sort/1...
Benchmarking sort/2...
Benchmarking sort_by/2...

Name                ips        average  deviation         median         99th %
sort/1           7.82 K      127.86 μs    ±23.45%         118 μs         269 μs
sort/2           7.01 K      142.57 μs    ±22.48%         132 μs         294 μs
sort_by/2        6.68 K      149.62 μs    ±22.70%         138 μs         308 μs

Comparison:
sort/1           7.82 K
sort/2           7.01 K - 1.12x slower +14.71 μs
sort_by/2        6.68 K - 1.17x slower +21.76 μs
```

#### Retrieving state from ets tables vs. Gen Servers [code](code/general/ets_vs_gen_server.exs)

There are many differences between Gen Servers and ets tables, but many people
have often praised ets tables for being extremely fast. For the simple case of
retrieving information from a key-value store, the ets table is indeed much
faster for reads. For more complicated use cases, and for comparisons of writes
instead of reads, further benchmarks are needed, but so far ets lives up to its
reputation for speed.

```
$ mix run code/general/ets_vs_gen_server.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 24 s

Benchmarking ets table...
Benchmarking gen server...

Name                 ips        average  deviation         median         99th %
ets table         5.11 M       0.196 μs  ±8972.86%           0 μs        0.98 μs
gen server        0.55 M        1.82 μs   ±997.04%        1.98 μs        2.98 μs

Comparison:
ets table         5.11 M
gen server        0.55 M - 9.31x slower +1.63 μs
```

#### Comparing strings vs. atoms [code](code/general/comparing_strings_vs_atoms.exs)

Because atoms are stored in a special table in the BEAM, comparing atoms is
rather fast compared to comparing strings, where you need to compare each part
of the list that underlies the string. When you have a choice of what type to
use, atoms is the faster choice. However, what you probably should not do is
to convert strings to atoms solely for the perceived speed benefit, since it
ends up being much slower than just comparing the strings, even dozens of times.

```
$ mix run code/general/comparing_strings_vs_atoms.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 ns
parallel: 1
inputs: Large (1-100), Medium (1-50), Small (1-5)
Estimated total run time: 1.80 min

Benchmarking Comparing atoms with input Large (1-100)...
Benchmarking Comparing atoms with input Medium (1-50)...
Benchmarking Comparing atoms with input Small (1-5)...
Benchmarking Comparing strings with input Large (1-100)...
Benchmarking Comparing strings with input Medium (1-50)...
Benchmarking Comparing strings with input Small (1-5)...
Benchmarking Converting to atoms and then comparing with input Large (1-100)...
Benchmarking Converting to atoms and then comparing with input Medium (1-50)...
Benchmarking Converting to atoms and then comparing with input Small (1-5)...

##### With input Large (1-100) #####
Name                                             ips        average  deviation         median         99th %
Comparing atoms                               3.74 M      267.46 ns ±12198.11%           0 ns        1000 ns
Comparing strings                             3.71 M      269.25 ns ±11719.28%           0 ns        1000 ns
Converting to atoms and then comparing        0.94 M     1065.67 ns   ±290.55%        1000 ns        2000 ns

Comparison:
Comparing atoms                               3.74 M
Comparing strings                             3.71 M - 1.01x slower +1.79 ns
Converting to atoms and then comparing        0.94 M - 3.98x slower +798.21 ns

##### With input Medium (1-50) #####
Name                                             ips        average  deviation         median         99th %
Comparing atoms                               3.70 M      270.08 ns ±11419.92%           0 ns        1000 ns
Comparing strings                             3.68 M      271.52 ns ±11603.67%           0 ns        1000 ns
Converting to atoms and then comparing        1.34 M      743.76 ns  ±2924.56%        1000 ns        1000 ns

Comparison:
Comparing atoms                               3.70 M
Comparing strings                             3.68 M - 1.01x slower +1.44 ns
Converting to atoms and then comparing        1.34 M - 2.75x slower +473.68 ns

##### With input Small (1-5) #####
Name                                             ips        average  deviation         median         99th %
Comparing atoms                               3.81 M      262.27 ns ±11438.39%           0 ns        1000 ns
Comparing strings                             3.69 M      270.86 ns ±11945.32%           0 ns        1000 ns
Converting to atoms and then comparing        2.45 M      407.62 ns  ±8371.44%           0 ns        1000 ns

Comparison:
Comparing atoms                               3.81 M
Comparing strings                             3.69 M - 1.03x slower +8.59 ns
Converting to atoms and then comparing        2.45 M - 1.55x slower +145.34 ns
```

### spawn vs. spawn_link [code](code/general/spawn_vs_spawn_link.exs)

There are two ways to spawn a process on the BEAM, `spawn` and `spawn_link`.
Because `spawn_link` links the child process to the process which spawned it, it
takes slightly longer. The way in which processes are spawned is unlikely to be
a bottleneck in most applications, though, and the resiliency benefits of OTP
supervision trees vastly outweighs the slightly slower run time of `spawn_link`,
so that should still be favored in nearly every case in which processes need to
be spawned.

```
$ mix run code/general/spawn_vs_spawn_link.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 28 s

Benchmarking spawn/1...
Benchmarking spawn_link/1...

Name                   ips        average  deviation         median         99th %
spawn/1           636.00 K        1.57 μs  ±1512.39%           1 μs           2 μs
spawn_link/1      576.18 K        1.74 μs  ±1402.58%           2 μs           2 μs

Comparison:
spawn/1           636.00 K
spawn_link/1      576.18 K - 1.10x slower +0.163 μs

Memory usage statistics:

Name            Memory usage
spawn/1                 72 B
spawn_link/1            72 B - 1.00x memory usage +0 B

**All measurements for memory usage were the same**
```

#### Replacements for Enum.filter_map/3 [code](code/general/filter_map.exs)

Elixir used to have an `Enum.filter_map/3` function that would filter a list and
also apply a function to each element in the list that was not removed, but it
was deprecated in version 1.5. Luckily there are still four other ways to do
that same thing! They're all mostly the same, but if you're looking for the
options with the best performance your best bet is to use either a `for`
comprehension or `Enum.reduce/3` and then `Enum.reverse/1`. Using
`Enum.filter/2` and then `Enum.map/2` is also a fine choice, but it has higher
memory usage than the other two options.

The one option you should avoid is using `Enum.flat_map/2` as it is both slower
and has higher memory usage.

```
$ mix run code/general/filter_map.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 10 ms
parallel: 1
inputs: Large, Medium, Small
Estimated total run time: 2.40 min

Benchmarking filter |> map with input Large...
Benchmarking filter |> map with input Medium...
Benchmarking filter |> map with input Small...
Benchmarking flat_map with input Large...
Benchmarking flat_map with input Medium...
Benchmarking flat_map with input Small...
Benchmarking for comprehension with input Large...
Benchmarking for comprehension with input Medium...
Benchmarking for comprehension with input Small...
Benchmarking reduce |> reverse with input Large...
Benchmarking reduce |> reverse with input Medium...
Benchmarking reduce |> reverse with input Small...

##### With input Large #####
Name                        ips        average  deviation         median         99th %
reduce |> reverse         12.12       82.51 ms     ±4.60%       81.46 ms       97.24 ms
for comprehension         12.12       82.51 ms     ±4.53%       81.87 ms       94.38 ms
filter |> map             10.78       92.75 ms     ±4.91%       92.15 ms      103.58 ms
flat_map                   8.41      118.89 ms     ±3.22%      118.22 ms      134.28 ms

Comparison:
reduce |> reverse         12.12
for comprehension         12.12 - 1.00x slower +0.00348 ms
filter |> map             10.78 - 1.12x slower +10.24 ms
flat_map                   8.41 - 1.44x slower +36.38 ms

Memory usage statistics:

Name                 Memory usage
reduce |> reverse         7.57 MB
for comprehension         7.57 MB - 1.00x memory usage +0 MB
filter |> map            13.28 MB - 1.75x memory usage +5.71 MB
flat_map                 14.32 MB - 1.89x memory usage +6.75 MB

**All measurements for memory usage were the same**

##### With input Medium #####
Name                        ips        average  deviation         median         99th %
for comprehension        1.27 K      788.69 μs    ±14.54%         732 μs     1287.38 μs
reduce |> reverse        1.26 K      792.37 μs    ±14.73%         732 μs     1283.97 μs
filter |> map            1.16 K      859.07 μs    ±14.68%         802 μs     1377.75 μs
flat_map                 0.86 K     1157.55 μs    ±15.68%        1093 μs     1838.80 μs

Comparison:
for comprehension        1.27 K
reduce |> reverse        1.26 K - 1.00x slower +3.68 μs
filter |> map            1.16 K - 1.09x slower +70.38 μs
flat_map                 0.86 K - 1.47x slower +368.87 μs

Memory usage statistics:

Name                 Memory usage
for comprehension        57.13 KB
reduce |> reverse        57.13 KB - 1.00x memory usage +0 KB
filter |> map           109.12 KB - 1.91x memory usage +51.99 KB
flat_map                130.66 KB - 2.29x memory usage +73.54 KB

**All measurements for memory usage were the same**

##### With input Small #####
Name                        ips        average  deviation         median         99th %
reduce |> reverse      121.39 K        8.24 μs   ±179.26%           8 μs          30 μs
for comprehension      121.20 K        8.25 μs   ±180.01%           8 μs          30 μs
filter |> map          111.29 K        8.99 μs   ±144.77%           8 μs          31 μs
flat_map                85.08 K       11.75 μs   ±119.95%          11 μs          37 μs

Comparison:
reduce |> reverse      121.39 K
for comprehension      121.20 K - 1.00x slower +0.0133 μs
filter |> map          111.29 K - 1.09x slower +0.75 μs
flat_map                85.08 K - 1.43x slower +3.52 μs

Memory usage statistics:

Name                 Memory usage
reduce |> reverse         1.09 KB
for comprehension         1.09 KB - 1.00x memory usage +0 KB
filter |> map             1.60 KB - 1.46x memory usage +0.51 KB
flat_map                  1.62 KB - 1.48x memory usage +0.52 KB

**All measurements for memory usage were the same**
```

#### String.slice/3 vs :binary.part/3 [code](code/general/string_slice.exs)

From `String.slice/3` [documentation](https://hexdocs.pm/elixir/String.html#slice/3):
Remember this function works with Unicode graphemes and considers the slices to represent grapheme offsets. If you want to split on raw bytes, check `Kernel.binary_part/3` instead.

```
$ mix run code/general/string_slice.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 100 ms
time: 2 s
memory time: 10 ms
parallel: 1
inputs: Large string (10 Thousand Numbers), Small string (10 Numbers)
Estimated total run time: 12.66 s

Benchmarking :binary.part/3 with input Large string (10 Thousand Numbers)...
Benchmarking :binary.part/3 with input Small string (10 Numbers)...
Benchmarking String.slice/3 with input Large string (10 Thousand Numbers)...
Benchmarking String.slice/3 with input Small string (10 Numbers)...
Benchmarking binary_part/3 with input Large string (10 Thousand Numbers)...
Benchmarking binary_part/3 with input Small string (10 Numbers)...

##### With input Large string (10 Thousand Numbers) #####
Name                     ips        average  deviation         median         99th %
binary_part/3        11.14 M       89.78 ns  ±2513.45%         100 ns         200 ns
:binary.part/3        3.59 M      278.65 ns  ±9466.55%           0 ns        1000 ns
String.slice/3        0.90 M     1112.12 ns   ±440.40%        1000 ns        2000 ns

Comparison:
binary_part/3        11.14 M
:binary.part/3        3.59 M - 3.10x slower +188.87 ns
String.slice/3        0.90 M - 12.39x slower +1022.34 ns

Memory usage statistics:

Name              Memory usage
binary_part/3              0 B
:binary.part/3             0 B - 1.00x memory usage +0 B
String.slice/3           880 B - ∞ x memory usage +880 B

**All measurements for memory usage were the same**

##### With input Small string (10 Numbers) #####
Name                     ips        average  deviation         median         99th %
binary_part/3         3.64 M      274.57 ns  ±7776.31%           0 ns        1000 ns
:binary.part/3        3.56 M      281.06 ns  ±9071.16%           0 ns        1000 ns
String.slice/3        0.91 M     1103.31 ns   ±246.39%        1000 ns        2000 ns

Comparison:
binary_part/3         3.64 M
:binary.part/3        3.56 M - 1.02x slower +6.48 ns
String.slice/3        0.91 M - 4.02x slower +828.73 ns

Memory usage statistics:

Name              Memory usage
binary_part/3              0 B
:binary.part/3             0 B - 1.00x memory usage +0 B
String.slice/3           880 B - ∞ x memory usage +880 B

**All measurements for memory usage were the same**
```

#### Filtering maps [code](code/general/filtering_maps.exs)

If we have a map and want to filter out key-value pairs from that map, there are
several ways to do it. However, because of some optimizations in Erlang,
`:maps.filter/2` is faster than any of the versions implemented in Elixir.
If you look at the benchmark code, you'll notice that the function used for
filtering takes two arguments (the key and value) instead of one (a tuple with
the key and value), and it's this difference that is responsible for the
decreased execution time and memory usage.

```
$ mix run code/general/filtering_maps.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i9-9880H CPU @ 2.30GHz
Number of Available Cores: 16
Available memory: 16 GB
Elixir 1.11.0-rc.0
Erlang 23.0.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 1 s
parallel: 1
inputs: Large (10_000), Medium (100), Small (1)
Estimated total run time: 2.60 min

Benchmarking :maps.filter with input Large (10_000)...
Benchmarking :maps.filter with input Medium (100)...
Benchmarking :maps.filter with input Small (1)...
Benchmarking Enum.filter/2 |> Enum.into/2 with input Large (10_000)...
Benchmarking Enum.filter/2 |> Enum.into/2 with input Medium (100)...
Benchmarking Enum.filter/2 |> Enum.into/2 with input Small (1)...
Benchmarking Enum.filter/2 |> Map.new/1 with input Large (10_000)...
Benchmarking Enum.filter/2 |> Map.new/1 with input Medium (100)...
Benchmarking Enum.filter/2 |> Map.new/1 with input Small (1)...
Benchmarking for with input Large (10_000)...
Benchmarking for with input Medium (100)...
Benchmarking for with input Small (1)...

##### With input Large (10_000) #####
Name                                   ips        average  deviation         median         99th %
:maps.filter                        669.86        1.49 ms    ±14.38%        1.44 ms        2.31 ms
Enum.filter/2 |> Enum.into/2        532.59        1.88 ms    ±19.86%        1.78 ms        2.87 ms
Enum.filter/2 |> Map.new/1          527.37        1.90 ms    ±25.17%        1.79 ms        2.85 ms
for                                 524.51        1.91 ms    ±31.33%        1.80 ms        2.83 ms

Comparison:
:maps.filter                        669.86
Enum.filter/2 |> Enum.into/2        532.59 - 1.26x slower +0.38 ms
Enum.filter/2 |> Map.new/1          527.37 - 1.27x slower +0.40 ms
for                                 524.51 - 1.28x slower +0.41 ms

Memory usage statistics:

Name                            Memory usage
:maps.filter                       780.45 KB
Enum.filter/2 |> Enum.into/2       782.85 KB - 1.00x memory usage +2.41 KB
Enum.filter/2 |> Map.new/1         782.87 KB - 1.00x memory usage +2.42 KB
for                                782.86 KB - 1.00x memory usage +2.41 KB

**All measurements for memory usage were the same**

##### With input Medium (100) #####
Name                                   ips        average  deviation         median         99th %
:maps.filter                       76.01 K       13.16 μs    ±90.13%          12 μs          42 μs
Enum.filter/2 |> Map.new/1         61.19 K       16.34 μs    ±61.27%          15 μs          50 μs
for                                60.89 K       16.42 μs    ±65.36%          15 μs          51 μs
Enum.filter/2 |> Enum.into/2       60.60 K       16.50 μs    ±60.52%          15 μs          51 μs

Comparison:
:maps.filter                       76.01 K
Enum.filter/2 |> Map.new/1         61.19 K - 1.24x slower +3.19 μs
for                                60.89 K - 1.25x slower +3.27 μs
Enum.filter/2 |> Enum.into/2       60.60 K - 1.25x slower +3.35 μs

Memory usage statistics:

Name                            Memory usage
:maps.filter                         5.67 KB
Enum.filter/2 |> Map.new/1           7.84 KB - 1.38x memory usage +2.17 KB
for                                  7.84 KB - 1.38x memory usage +2.17 KB
Enum.filter/2 |> Enum.into/2         7.84 KB - 1.38x memory usage +2.17 KB

**All measurements for memory usage were the same**

##### With input Small (1) #####
Name                                   ips        average  deviation         median         99th %
:maps.filter                        2.46 M      406.55 ns  ±6862.02%           0 ns        1000 ns
for                                 1.81 M      551.70 ns  ±4974.10%           0 ns        1000 ns
Enum.filter/2 |> Map.new/1          1.78 M      562.13 ns  ±5004.53%           0 ns        1000 ns
Enum.filter/2 |> Enum.into/2        1.64 M      608.18 ns  ±4796.51%        1000 ns        1000 ns

Comparison:
:maps.filter                        2.46 M
for                                 1.81 M - 1.36x slower +145.15 ns
Enum.filter/2 |> Map.new/1          1.78 M - 1.38x slower +155.58 ns
Enum.filter/2 |> Enum.into/2        1.64 M - 1.50x slower +201.63 ns

Memory usage statistics:

Name                            Memory usage
:maps.filter                           136 B
for                                    248 B - 1.82x memory usage +112 B
Enum.filter/2 |> Map.new/1             248 B - 1.82x memory usage +112 B
Enum.filter/2 |> Enum.into/2           248 B - 1.82x memory usage +112 B

**All measurements for memory usage were the same**
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
