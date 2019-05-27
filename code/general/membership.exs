defmodule Membership.NewMapSetMember do
  def check_membership(range, list, _mapset) do
    find = Enum.random(range)
    mapset = MapSet.new(list)
    MapSet.member?(mapset, find)
  end
end

defmodule Membership.MapSetMember do
  def check_membership(range, _list, mapset) do
    find = Enum.random(range)
    MapSet.member?(mapset, find)
  end
end

defmodule Membership.EnumMember do
  def check_membership(range, list, _mapset) do
    find = Enum.random(range)
    Enum.member?(list, find)
  end
end

defmodule Membership.EnumAny do
  def check_membership(range, list, _mapset) do
    find = Enum.random(range)
    Enum.any?(list, &(&1 == find))
  end
end

defmodule Membership.In do
  def check_membership(range, list, _mapset) do
    find = Enum.random(range)
    find in list
  end
end

defmodule Membership.Benchmark do
  @inputs %{
    "Large (pass)" => {1..1_000_000, Enum.shuffle(1..1_000_000), MapSet.new(1..1_000_000)},
    "Large (fail)" =>
      {1_000_001..2_000_000, Enum.shuffle(1..1_000_000), MapSet.new(1..1_000_000)},
    "Medium (pass)" => {1..10_000, Enum.shuffle(1..10_000), MapSet.new(1..10_000)},
    "Medium (fail)" => {10_001..20_000, Enum.shuffle(1..10_000), MapSet.new(1..10_000)},
    "Small (pass)" => {1..100, Enum.shuffle(1..100), MapSet.new(1..100)},
    "Small (fail)" => {101..200, Enum.shuffle(1..100), MapSet.new(1..100)}
  }

  def benchmark do
    Benchee.run(
      %{
        "New MapSet + MapSet.member?" => fn input -> bench(Membership.NewMapSetMember, input) end,
        "MapSet.member?" => fn input -> bench(Membership.MapSetMember, input) end,
        "Enum.member?" => fn input -> bench(Membership.EnumMember, input) end,
        "Enum.any?" => fn input -> bench(Membership.EnumAny, input) end,
        "x in y" => fn input -> bench(Membership.In, input) end
      },
      time: 10,
      inputs: @inputs,
      print: [fast_warning: false]
    )
  end

  defp bench(module, {range, list, mapset}) do
    module.check_membership(range, list, mapset)
  end
end

Membership.Benchmark.benchmark()
