defmodule PrefixedSearchTest do
  use ExUnit.Case, async: true
  use PropCheck

  @numtests (System.get_env("N") || "100") |> String.to_integer
  @opts [:quiet, {:numtests, @numtests}]

  property "can always find each key by all of its prefixes", @opts do
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

  property "any key can be prefix-searched", @opts do
    forall {keys, queries} <- {list(utf8()), list(utf8())} do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.all?(queries, fn(query) ->
        is_map(Patriecia.prefixed(trie, query))
      end)
    end
  end

  property "everything is matched by a \"\" prefix search", @opts do
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
