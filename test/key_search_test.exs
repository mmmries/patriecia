defmodule KeySearchTest do
  use ExUnit.Case, async: true

  setup do
    trie =
      Patriecia.new()
      |> Patriecia.add("apple", 1)
      |> Patriecia.add("apricot", 2)
      |> Patriecia.add("apple", 3)

    {:ok, %{trie: trie}}
  end

  test "searching an empty trie" do
    trie = Patriecia.new()
    assert Patriecia.key(trie, "a") == MapSet.new()
  end

  test "searching for a key that does not exist", %{trie: trie} do
    assert Patriecia.key(trie, "apples") == MapSet.new()
  end

  test "search for a key with one match", %{trie: trie} do
    assert Patriecia.key(trie, "apricot") == MapSet.new([2])
  end

  test "search for a key with multiple matches", %{trie: trie} do
    assert Patriecia.key(trie, "apple") == MapSet.new([1, 3])
  end
end
