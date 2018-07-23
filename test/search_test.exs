defmodule SearchTest do
  use ExUnit.Case, async: true

  setup do
    trie =
      Patriecia.new()
      |> Patriecia.add("apple", 1)
      |> Patriecia.add("banana", 2)
      |> Patriecia.add("plum", 3)
      |> Patriecia.add("apples", 1)
      |> Patriecia.add("bananas", 2)
      |> Patriecia.add("plums", 3)
      |> Patriecia.add("apricot", 4)
      |> Patriecia.add("peach", 5)

    {:ok, %{trie: trie}}
  end

  test "searching an empty trie" do
    assert Patriecia.new() |> Patriecia.prefixed("a") == MapSet.new()
  end

  test "searching for a prefix that does not exist", %{trie: trie} do
    assert Patriecia.prefixed(trie, "zoo") == MapSet.new()
  end

  test "searching for a prefix that is longer than existing keys", %{trie: trie} do
    assert Patriecia.prefixed(trie, "applesauce") == MapSet.new()
  end

  test "results are unique", %{trie: trie} do
    assert Patriecia.prefixed(trie, "apple") == MapSet.new([1])
  end

  test "results include everything with the specified prefix", %{trie: trie} do
    assert Patriecia.prefixed(trie, "ap") == MapSet.new([1, 4])
    assert Patriecia.prefixed(trie, "b") == MapSet.new([2])
  end
end
