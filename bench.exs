words = "/usr/share/dict/words" |> File.read! |> String.split("\n")
trie = Enum.reduce(words, Patriecia.new(), fn(word, t) -> Patriecia.add(t, word, true) end)

Benchee.run(
  %{
    "build trie" => fn -> Enum.reduce(words, Patriecia.new(), fn(word, t) -> Patriecia.add(t, word, true) end) end,
    "key search" => fn -> Patriecia.key(trie, "apple") end,
    "prefix search" => fn -> Patriecia.prefixed(trie, "apple") end,
  },
  time: 10,
  memory_time: 2,
  warmup: 3
)
