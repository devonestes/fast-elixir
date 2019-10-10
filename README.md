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
- [Splitting Large Strings](#splitting-large-strings-code)
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
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
parallel: 1
inputs: none specified
Estimated total run time: 24 s


Benchmarking Map Lookup...
Benchmarking Pattern Matching...

Name                       ips        average  deviation         median         99th %
Pattern Matching      891.15 K        1.12 μs   ±458.04%           1 μs           2 μs
Map Lookup            671.59 K        1.49 μs   ±385.22%        1.40 μs           3 μs

Comparison:
Pattern Matching      891.15 K
Map Lookup            671.59 K - 1.33x slower
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
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
parallel: 1
inputs: none specified
Estimated total run time: 24 s


Benchmarking IO List...
Benchmarking Interpolation...


Name                    ips        average  deviation         median         99th %
IO List             17.85 K       56.03 μs   ±472.47%          44 μs         132 μs
Interpolation       16.25 K       61.53 μs   ±436.51%          47 μs         149 μs

Comparison:
IO List             17.85 K
Interpolation       16.25 K - 1.10x slower
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
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
parallel: 1
inputs: Large (30,000 items), Medium (3,000 items), Small (30 items)
Estimated total run time: 1.80 min


Benchmarking Concatenation with input Large (30,000 items)...
Benchmarking Concatenation with input Medium (3,000 items)...
Benchmarking Concatenation with input Small (30 items)...
Benchmarking Cons + Flatten with input Large (30,000 items)...
Benchmarking Cons + Flatten with input Medium (3,000 items)...
Benchmarking Cons + Flatten with input Small (30 items)...
Benchmarking Cons + Reverse + Flatten with input Large (30,000 items)...
Benchmarking Cons + Reverse + Flatten with input Medium (3,000 items)...
Benchmarking Cons + Reverse + Flatten with input Small (30 items)...

##### With input Large (30,000 items) #####
Name                               ips        average  deviation         median         99th %
Cons + Flatten                 1050.17        0.95 ms    ±21.56%        0.91 ms        1.76 ms
Cons + Reverse + Flatten        963.62        1.04 ms    ±20.34%        0.95 ms        1.88 ms
Concatenation                     1.15      873.22 ms     ±7.07%      849.37 ms     1057.06 ms

Comparison:
Cons + Flatten                 1050.17
Cons + Reverse + Flatten        963.62 - 1.09x slower
Concatenation                     1.15 - 917.03x slower

##### With input Medium (3,000 items) #####
Name                               ips        average  deviation         median         99th %
Cons + Flatten                 11.43 K       87.45 μs    ±23.38%          79 μs      166.32 μs
Cons + Reverse + Flatten       10.88 K       91.93 μs    ±83.54%          82 μs         185 μs
Concatenation                  0.138 K     7263.24 μs    ±14.32%        6884 μs    11724.06 μs

Comparison:
Cons + Flatten                 11.43 K
Cons + Reverse + Flatten       10.88 K - 1.05x slower
Concatenation                  0.138 K - 83.05x slower

##### With input Small (30 items) #####
Name                               ips        average  deviation         median         99th %
Cons + Reverse + Flatten      891.07 K        1.12 μs   ±336.67%           1 μs           2 μs
Cons + Flatten                890.95 K        1.12 μs   ±473.42%           1 μs        2.10 μs
Concatenation                 717.19 K        1.39 μs  ±6508.63%           1 μs           2 μs

Comparison:
Cons + Reverse + Flatten      891.07 K
Cons + Flatten                890.95 K - 1.00x slower
Concatenation                 717.19 K - 1.24x slower
```

#### Putting into maps with `Map.put` and `put_in` [code](code/general/map_put_vs_put_in.exs)

Do not put data into root of map with `put_in`. It is ~2x slower than `Map.put`. Also `put_in/2` is more effective than `put_in/3`.

```
Operating System: macOS"
CPU Information: Intel(R) Core(TM) i7-3520M CPU @ 2.90GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.7.4
Erlang 21.2.2

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 0 μs
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
Map.put/3        265.12        3.77 ms    ±47.11%        3.33 ms       11.35 ms
put_in/2         186.31        5.37 ms    ±21.17%        5.15 ms        8.67 ms
put_in/3         158.40        6.31 ms    ±34.23%        5.84 ms       14.71 ms

Comparison:
Map.put/3        265.12
put_in/2         186.31 - 1.42x slower
put_in/3         158.40 - 1.67x slower

##### With input Medium (3,000 items) #####
Name                ips        average  deviation         median         99th %
Map.put/3        5.68 K      175.93 μs   ±143.04%         151 μs         476 μs
put_in/2         2.73 K      366.60 μs    ±34.11%         334 μs         829 μs
put_in/3         2.44 K      409.76 μs    ±30.36%         372 μs      854.51 μs

Comparison:
Map.put/3        5.68 K
put_in/2         2.73 K - 2.08x slower
put_in/3         2.44 K - 2.33x slower

##### With input Small (30 items) #####
Name                ips        average  deviation         median         99th %
Map.put/3      677.44 K        1.48 μs  ±2879.99%           1 μs           3 μs
put_in/2       362.48 K        2.76 μs  ±1833.30%           2 μs           5 μs
put_in/3       337.47 K        2.96 μs  ±1141.45%           3 μs           5 μs

Comparison:
Map.put/3      677.44 K
put_in/2       362.48 K - 1.87x slower
put_in/3       337.47 K - 2.01x slower
```

#### Splitting Large Strings [code](code/general/string_split_large_strings.exs)

Due to a known issue in Erlang, splitting very large strings can be done faster
using Elixir's streaming approach rather than using `String.split/2`.

```
$ mix run code/general/string_split_large_strings.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
parallel: 1
inputs: Large string (1 Million Numbers), Medium string (10 Thousand Numbers), Small string (1 Hundred Numbers)
Estimated total run time: 1.20 min


Benchmarking split with input Large string (1 Million Numbers)...
Benchmarking split with input Medium string (10 Thousand Numbers)...
Benchmarking split with input Small string (1 Hundred Numbers)...
Benchmarking splitter |> to_list with input Large string (1 Million Numbers)...
Benchmarking splitter |> to_list with input Medium string (10 Thousand Numbers)...
Benchmarking splitter |> to_list with input Small string (1 Hundred Numbers)...

##### With input Large string (1 Million Numbers) #####
Name                          ips        average  deviation         median         99th %
splitter |> to_list          2.81         0.36 s    ±17.24%         0.34 s         0.52 s
split                        0.29         3.48 s     ±0.24%         3.49 s         3.49 s

Comparison:
splitter |> to_list          2.81
split                        0.29 - 9.78x slower

##### With input Medium string (10 Thousand Numbers) #####
Name                          ips        average  deviation         median         99th %
split                      1.73 K        0.58 ms    ±34.42%        0.71 ms        0.86 ms
splitter |> to_list        0.33 K        3.04 ms    ±18.95%        3.11 ms        4.76 ms

Comparison:
split                      1.73 K
splitter |> to_list        0.33 K - 5.25x slower

##### With input Small string (1 Hundred Numbers) #####
Name                          ips        average  deviation         median         99th %
split                    302.83 K        3.30 μs  ±1848.10%           3 μs           6 μs
splitter |> to_list       48.08 K       20.80 μs   ±215.29%          18 μs          82 μs

Comparison:
split                    302.83 K
splitter |> to_list       48.08 K - 6.30x slower
```

#### `sort` vs. `sort_by` [code](code/general/sort_vs_sort_by.exs)

Sorting a list of maps or keyword lists can be done in various ways, given that
the key-value you want to sort on is the first one defined in the associative
data structure. The speed differences are minimal.

```
$ mix run code/general/sort_vs_sort_by.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
parallel: 1
inputs: none specified
Estimated total run time: 36 s


Benchmarking sort/1...
Benchmarking sort/2...
Benchmarking sort_by/2...

Name                ips        average  deviation         median         99th %
sort/1           4.93 K      202.65 μs    ±21.42%         191 μs         409 μs
sort/2           4.74 K      210.76 μs    ±18.83%         199 μs         394 μs
sort_by/2        4.53 K      220.71 μs    ±34.84%         204 μs         438 μs

Comparison:
sort/1           4.93 K
sort/2           4.74 K - 1.04x slower
sort_by/2        4.53 K - 1.09x slower
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
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
parallel: 1
inputs: none specified
Estimated total run time: 24 s


Benchmarking ets table...
Benchmarking gen server...

Name                 ips        average  deviation         median         99th %
ets table         9.12 M       0.110 μs   ±365.39%       0.100 μs        0.23 μs
gen server        0.29 M        3.46 μs  ±2532.35%           3 μs          10 μs

Comparison:
ets table         9.12 M
gen server        0.29 M - 31.53x slower
```

#### Comparing strings vs. atoms [code](code/general/comparing_strings_vs_atoms.exs)

Because atoms are stored in a special table in the BEAM, comparing atoms is
rather fast compared to comparing strings, where you need to compare each part
of the list that underlies the string. When you have a choice of what type to
use, atoms is the faster choice. However, what you probably should not do is
to convert strings to atoms solely for the perceived speed benefit, since it
ends up being much slower than just comparing the strings, even dozens of times.

```
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.6.3
Erlang 20.3
Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
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
Comparing atoms                               8.12 M       0.123 μs    ±54.10%       0.120 μs        0.22 μs
Comparing strings                             6.94 M       0.144 μs    ±75.54%       0.140 μs        0.25 μs
Converting to atoms and then comparing        0.68 M        1.47 μs   ±350.78%           1 μs           2 μs

Comparison:
Comparing atoms                               8.12 M
Comparing strings                             6.94 M - 1.17x slower
Converting to atoms and then comparing        0.68 M - 11.95x slower

##### With input Medium (1-50) #####
Name                                             ips        average  deviation         median         99th %
Comparing atoms                               8.05 M       0.124 μs    ±86.21%       0.120 μs        0.23 μs
Comparing strings                             6.91 M       0.145 μs    ±76.74%       0.140 μs        0.25 μs
Converting to atoms and then comparing        1.00 M        1.00 μs   ±441.77%           1 μs           2 μs

Comparison:
Comparing atoms                               8.05 M
Comparing strings                             6.91 M - 1.17x slower
Converting to atoms and then comparing        1.00 M - 8.08x slower

##### With input Small (1-5) #####
Name                                             ips        average  deviation         median         99th %
Comparing atoms                               7.99 M       0.125 μs    ±85.13%       0.120 μs        0.22 μs
Comparing strings                             6.83 M       0.146 μs    ±78.46%       0.140 μs        0.25 μs
Converting to atoms and then comparing        2.64 M        0.38 μs    ±51.12%        0.37 μs        0.59 μs

Comparison:
Comparing atoms                               7.99 M
Comparing strings                             6.83 M - 1.17x slower
Converting to atoms and then comparing        2.64 M - 3.03x slower
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
Operating System: macOS
CPU Information: Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz
Number of Available Cores: 4
Available memory: 8 GB
Elixir 1.7.1
Erlang 21.0

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
spawn/1           507.24 K        1.97 μs  ±1950.75%           2 μs           3 μs
spawn_link/1      436.03 K        2.29 μs  ±1224.66%           2 μs           4 μs

Comparison:
spawn/1           507.24 K
spawn_link/1      436.03 K - 1.16x slower

Memory usage statistics:

Name            Memory usage
spawn/1                144 B
spawn_link/1           144 B - 1.00x memory usage

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
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz
Number of Available Cores: 8
Available memory: 15.39 GB
Elixir 1.8.1
Erlang 21.2.6

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

##### With input Small #####
Name                        ips        average  deviation         median         99th %
reduce |> reverse      167.19 K        5.98 μs   ±308.23%        5.18 μs       12.07 μs
filter |> map          163.15 K        6.13 μs   ±296.65%        5.16 μs       11.98 μs
for comprehension      157.76 K        6.34 μs   ±269.05%        5.39 μs       12.38 μs
flat_map               116.20 K        8.61 μs   ±192.50%        7.69 μs       16.06 μs

Comparison:
reduce |> reverse      167.19 K
filter |> map          163.15 K - 1.02x slower
for comprehension      157.76 K - 1.06x slower
flat_map               116.20 K - 1.44x slower

Memory usage statistics:

Name                 Memory usage
reduce |> reverse         1.19 KB
filter |> map             1.70 KB - 1.43x memory usage
for comprehension         1.19 KB - 1.00x memory usage
flat_map                  1.59 KB - 1.34x memory usage

**All measurements for memory usage were the same**

##### With input Medium #####
Name                        ips        average  deviation         median         99th %
reduce |> reverse        1.76 K      569.19 μs    ±17.54%      532.00 μs     1035.91 μs
for comprehension        1.73 K      579.06 μs    ±14.77%      548.57 μs      938.81 μs
filter |> map            1.72 K      582.49 μs    ±19.98%      536.60 μs     1069.09 μs
flat_map                 1.21 K      824.01 μs    ±18.25%      765.08 μs     1535.27 μs

Comparison:
reduce |> reverse        1.76 K
for comprehension        1.73 K - 1.02x slower
filter |> map            1.72 K - 1.02x slower
flat_map                 1.21 K - 1.45x slower

Memory usage statistics:

Name                 Memory usage
reduce |> reverse        57.13 KB
for comprehension        57.13 KB - 1.00x memory usage
filter |> map           109.15 KB - 1.91x memory usage
flat_map                117.48 KB - 2.06x memory usage

**All measurements for memory usage were the same**

##### With input Large #####
Name                        ips        average  deviation         median         99th %
for comprehension         16.48       60.68 ms    ±11.70%       58.62 ms       91.09 ms
filter |> map             16.35       61.15 ms    ±12.88%       59.24 ms       89.90 ms
reduce |> reverse         16.20       61.72 ms    ±14.36%       57.73 ms       83.17 ms
flat_map                  11.71       85.43 ms    ±13.90%       78.94 ms      113.50 ms

Comparison:
for comprehension         16.48
filter |> map             16.35 - 1.01x slower
reduce |> reverse         16.20 - 1.02x slower
flat_map                  11.71 - 1.41x slower

Memory usage statistics:

Name                 Memory usage
for comprehension         8.16 MB
filter |> map            13.34 MB - 1.63x memory usage
reduce |> reverse         8.16 MB - 1.00x memory usage
flat_map                 13.64 MB - 1.67x memory usage

**All measurements for memory usage were the same**
```

#### String.slice/3 vs :binary.part/3 [code](code/general/string_slice.exs)

From `String.slice/3` [documentation](https://hexdocs.pm/elixir/String.html#slice/3):
Remember this function works with Unicode graphemes and considers the slices to represent grapheme offsets. If you want to split on raw bytes, check `Kernel.binary_part/3` instead.

```
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
Number of Available Cores: 12
Available memory: 16 GB
Elixir 1.9.1
Erlang 22.0.7

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
binary_part/3        17.23 M       58.03 ns  ±4513.98%          80 ns         180 ns
:binary.part/3        3.96 M      252.32 ns  ±8577.24%           0 ns         980 ns
String.slice/3        1.39 M      720.21 ns   ±755.41%         980 ns         980 ns

Comparison:
binary_part/3        17.23 M
:binary.part/3        3.96 M - 4.35x slower +194.29 ns
String.slice/3        1.39 M - 12.41x slower +662.18 ns

Memory usage statistics:

Name              Memory usage
binary_part/3              0 B
:binary.part/3             0 B - 1.00x memory usage +0 B
String.slice/3           880 B - ∞ x memory usage +880 B

**All measurements for memory usage were the same**

##### With input Small string (10 Numbers) #####
Name                     ips        average  deviation         median         99th %
binary_part/3        17.25 M       57.97 ns  ±4482.36%          80 ns         180 ns
:binary.part/3       15.71 M       63.64 ns  ±6789.17%          80 ns          80 ns
String.slice/3        1.38 M      726.17 ns  ±1532.43%         980 ns         980 ns

Comparison:
binary_part/3        17.25 M
:binary.part/3       15.71 M - 1.10x slower +5.67 ns
String.slice/3        1.38 M - 12.53x slower +668.20 ns

Memory usage statistics:

Name              Memory usage
binary_part/3              0 B
:binary.part/3             0 B - 1.00x memory usage +0 B
String.slice/3           880 B - ∞ x memory usage +880 B

**All measurements for memory usage were the same**
```

#### Filtering maps [code](code/general/string_slice.exs)

If we have a map and want to filter out key-value pairs from that map, there are
several ways to do it. However, because of some optimizations in Erlang,
`:maps.filter/2` is faster than any of the versions implemented in Elixir.
If you look at the benchmark code, you'll notice that the function used for
filtering takes two arguments (the key and value) instead of one (a tuple with
the key and value), and it's this difference that is responsible for the
decreased execution time and memory usage.

```
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-8750H CPU @ 2.20GHz
Number of Available Cores: 12
Available memory: 16 GB
Elixir 1.9.1
Erlang 22.1.2

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
:maps.filter                        787.95        1.27 ms    ±17.36%        1.24 ms        2.09 ms
for                                 734.04        1.36 ms    ±24.47%        1.31 ms        1.85 ms
Enum.filter/2 |> Enum.into/2        712.02        1.40 ms    ±29.52%        1.37 ms        1.83 ms
Enum.filter/2 |> Map.new/1          704.65        1.42 ms    ±27.76%        1.38 ms        1.89 ms

Comparison:
:maps.filter                        787.95
for                                 734.04 - 1.07x slower +0.0932 ms
Enum.filter/2 |> Enum.into/2        712.02 - 1.11x slower +0.135 ms
Enum.filter/2 |> Map.new/1          704.65 - 1.12x slower +0.150 ms

Memory usage statistics:

Name                            Memory usage
:maps.filter                       700.70 KB
for                                802.84 KB - 1.15x memory usage +102.14 KB
Enum.filter/2 |> Enum.into/2       802.86 KB - 1.15x memory usage +102.16 KB
Enum.filter/2 |> Map.new/1         802.86 KB - 1.15x memory usage +102.16 KB

**All measurements for memory usage were the same**

##### With input Medium (100) #####
Name                                   ips        average  deviation         median         99th %
:maps.filter                      100.64 K        9.94 μs   ±175.28%           9 μs          26 μs
Enum.filter/2 |> Map.new/1         85.42 K       11.71 μs   ±110.89%          11 μs          32 μs
for                                81.34 K       12.29 μs   ±132.99%          11 μs          32 μs
Enum.filter/2 |> Enum.into/2       80.41 K       12.44 μs   ±120.11%          12 μs          31 μs

Comparison:
:maps.filter                      100.64 K
Enum.filter/2 |> Map.new/1         85.42 K - 1.18x slower +1.77 μs
for                                81.34 K - 1.24x slower +2.36 μs
Enum.filter/2 |> Enum.into/2       80.41 K - 1.25x slower +2.50 μs

Memory usage statistics:

Name                            Memory usage
:maps.filter                         5.70 KB
Enum.filter/2 |> Map.new/1           7.84 KB - 1.38x memory usage +2.15 KB
for                                  7.84 KB - 1.38x memory usage +2.15 KB
Enum.filter/2 |> Enum.into/2         7.84 KB - 1.38x memory usage +2.15 KB

**All measurements for memory usage were the same**

##### With input Small (1) #####
Name                                   ips        average  deviation         median         99th %
:maps.filter                        2.74 M      365.22 ns  ±9695.02%           0 ns        1000 ns
for                                 2.05 M      487.50 ns  ±6665.49%           0 ns        1000 ns
Enum.filter/2 |> Map.new/1          1.97 M      508.17 ns  ±9786.44%           0 ns        1000 ns
Enum.filter/2 |> Enum.into/2        1.86 M      536.23 ns ±10066.95%           0 ns        1000 ns

Comparison:
:maps.filter                        2.74 M
for                                 2.05 M - 1.33x slower +122.28 ns
Enum.filter/2 |> Map.new/1          1.97 M - 1.39x slower +142.95 ns
Enum.filter/2 |> Enum.into/2        1.86 M - 1.47x slower +171.01 ns

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
