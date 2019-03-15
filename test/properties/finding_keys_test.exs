defmodule FindingKeysTest do
  use ExUnit.Case, async: true
  use PropCheck

  property "can find any of the initial keys we put in" do
    forall keys <- list(utf8()) do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.each(keys, fn(key) ->
        result = Patriecia.key(trie, key)
        true = MapSet.member?(result, key)
      end)
      true
    end
  end

  property "can always find each key by prefix searching itself" do
    forall keys <- list(utf8()) do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.each(keys, fn(key) ->
        result = Patriecia.prefixed(trie, key)
        true = MapSet.member?(result, key)
      end)
      true
    end
  end

  property "can always find each key by all of its prefixes" do
    forall keys <- list(utf8()) do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.each(keys, fn(key) ->
        key |> all_possible_prefixes() |> Enum.each(fn(pre) ->
          result = Patriecia.prefixed(trie, pre)
          true = MapSet.member?(result, key)
        end)
      end)
      true
    end
  end

  property "any key can be searched" do
    forall {keys, queries} <- {list(utf8()), list(utf8())} do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.all?(queries, fn(query) ->
        is_map(Patriecia.key(trie, query))
      end)
    end
  end

  property "any key can be prefix-searched" do
    forall {keys, queries} <- {list(utf8()), list(utf8())} do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.all?(queries, fn(query) ->
        is_map(Patriecia.prefixed(trie, query))
      end)
    end
  end

  property "everything is match by a \"\" prefix search" do
    forall keys <- list(utf8()) do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Patriecia.prefixed(trie, "") == MapSet.new(keys)
    end
  end

  def all_possible_prefixes(<<>>), do: [<<>>]
  def all_possible_prefixes(bin) do
    next = :binary.part(bin, 0, byte_size(bin) - 1)
    [bin | all_possible_prefixes(next)]
  end
end
