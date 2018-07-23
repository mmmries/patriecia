defmodule PatrieciaTest do
  use ExUnit.Case
  doctest Patriecia

  test "an empty trie" do
    assert Patriecia.new() |> Map.get(:root) == nil
  end

  test "a trie with a single node" do
    trie = Patriecia.new() |> Patriecia.add("key", 1)
    assert trie.root == %{part: "key", values: MapSet.new([1])}
  end

  test "inserting another record with a duplicate key" do
    trie = Patriecia.new() |> Patriecia.add("key", 1) |> Patriecia.add("key", 2)
    assert trie.root == %{part: "key", values: MapSet.new([1, 2])}
  end

  test "a trie with overlapping keys" do
    trie =
      Patriecia.new()
      |> Patriecia.add("key", 1)
      |> Patriecia.add("keyper", 2)

    assert trie.root == %{
             :part => "key",
             :values => MapSet.new([1]),
             ?p => %{part: "per", values: MapSet.new([2])}
           }
  end

  test "a trie with disjoint keys" do
    trie =
      Patriecia.new()
      |> Patriecia.add("key", 1)
      |> Patriecia.add("zoo", 2)

    assert trie.root == %{
             :part => "",
             :values => MapSet.new(),
             ?k => %{part: "key", values: MapSet.new([1])},
             ?z => %{part: "zoo", values: MapSet.new([2])}
           }
  end
end
