defmodule Lookup.Slow do
  @lookup %{
    "one"   => 1,
    "two"   => 2,
    "three" => 3,
    "four"  => 4,
    "five"  => 5
  }

  def int_for(str) do
    @lookup[str]
  end
end

defmodule Lookup.FastDidatic do
  @moduledoc """
  This is a didatic implementation which illustrates the code as the compiler sees it.
  The downside is that if our key-value structure grows, the code becomes unwieldy.
  """

  # The base-clause can be declared without a do-block, which helps with readability.
  def int_for(str)

  def int_for("one"),   do: 1
  def int_for("two"),   do: 2
  def int_for("three"), do: 3
  def int_for("four"),  do: 4
  def int_for("five"),  do: 5
end

defmodule Lookup.FastPractical do
  @moduledoc """
  This is a more realistic implementation of the fast lookup structure through function head matching.

  This also has the advantage of allowing the user to define the map as they see fit.
  For instance, one could load the map from a file declared as an `@external_resource`.
  """

  @lookup %{
    "one"   => 1,
    "two"   => 2,
    "three" => 3,
    "four"  => 4,
    "five"  => 5
  }

  # The base-clause can be declared without a do-block, which helps with readability.
  def int_for(str)

  # The following iterations will generate the claused from the previously defined map.
  # `unquote`s are needed so we inject the values themselves instead of declaring arguments
  # in the function head or accessing a variable/calling a zero-arity function in the body
  Enum.each(@lookup, fn {k, v} ->
    def int_for(unquote(k)), do: unquote(v)
  end)
end

defmodule Lookup.Benchmark do
  def benchmark do
    Benchee.run(%{
      "Pattern Matching with Didatic Implementation" => fn -> bench_func(Lookup.FastDidatic) end,
      "Pattern Matching with Practical Implementation" => fn -> bench_func(Lookup.FastPractical) end,
      "Map Lookup"       => fn -> bench_func(Lookup.Slow) end
    }, time: 10, print: [fast_warning: false])
  end

  def bench_func(module) do
    module.int_for("one")
    module.int_for("two")
    module.int_for("three")
    module.int_for("four")
    module.int_for("five")
    module.int_for("one")
    module.int_for("two")
    module.int_for("three")
    module.int_for("four")
    module.int_for("five")
    module.int_for("one")
    module.int_for("two")
    module.int_for("three")
    module.int_for("four")
    module.int_for("five")
  end
end

Lookup.Benchmark.benchmark()
