defmodule FindingKeysTest do
  use ExUnit.Case, async: true
  use PropCheck

  @numtests (System.get_env("N") || "100") |> String.to_integer
  @opts [:quiet, {:numtests, @numtests}]

  property "can find any of the initial keys we put in", @opts do
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

  property "any key can be searched", @opts do
    forall {keys, queries} <- {list(utf8()), list(utf8())} do
      trie = Enum.reduce(keys, Patriecia.new(), fn(key, trie) ->
        Patriecia.add(trie, key, key)
      end)
      Enum.all?(queries, fn(query) ->
        is_map(Patriecia.key(trie, query))
      end)
    end
  end
end
