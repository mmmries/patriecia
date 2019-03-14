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
end
