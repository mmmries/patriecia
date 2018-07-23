defmodule Patriecia do
  defstruct [:root]

  def new, do: %__MODULE__{}

  def add(%__MODULE__{root: root} = trie, key, record) do
    root = do_add(root, key, record)
    %{trie | root: root}
  end

  def prefixed(%__MODULE__{root: root}, prefix) do
    do_prefixed(root, prefix, MapSet.new())
  end

  defp do_add(nil, key, record) do
    %{part: key, values: MapSet.new([record])}
  end

  defp do_add(%{part: part} = node, part, record) do
    %{node | values: MapSet.put(node.values, record)}
  end

  defp do_add(%{part: part} = node, key, record) do
    cond do
      String.starts_with?(key, part) ->
        add_child(node, key, record)

      true ->
        shared_part = find_shared_part(part, key)

        %{part: shared_part, values: MapSet.new()}
        |> re_add_child(part, node.values)
        |> add_child(key, record)
    end
  end

  defp do_prefixed(nil, _prefix, results), do: results

  defp do_prefixed(%{part: part} = node, part, results) do
    do_gather_results(node, results)
  end

  defp do_prefixed(%{part: part} = node, prefix, results) do
    cond do
      String.starts_with?(prefix, part) ->
        part_size = byte_size(part)
        rest = :binary.part(prefix, part_size, byte_size(prefix) - part_size)
        <<next, _::binary>> = rest
        do_prefixed(Map.get(node, next), rest, results)

      String.starts_with?(part, prefix) ->
        do_gather_results(node, results)
    end
  end

  defp do_gather_results(%{values: values} = node, results) do
    results = MapSet.union(results, values)

    Enum.reduce(Map.keys(node), results, fn
      :part, results -> results
      :values, results -> results
      next, results -> Map.get(node, next) |> do_gather_results(results)
    end)
  end

  defp add_child(%{part: part} = node, part, record) do
    Map.put(node, :values, MapSet.put(node.values, record))
  end

  defp add_child(%{part: part} = node, key, record) do
    part_size = byte_size(part)
    rest = :binary.part(key, {part_size, byte_size(key) - part_size})
    <<next, _::binary>> = rest
    Map.put(node, next, do_add(Map.get(node, next), rest, record))
  end

  defp re_add_child(%{part: part} = node, key, records) do
    part_size = byte_size(part)
    rest = :binary.part(key, {part_size, byte_size(key) - part_size})
    <<next, _::binary>> = rest
    Map.put(node, next, %{part: rest, values: records})
  end

  defp find_shared_part(bin1, bin2) do
    :binary.part(bin1, 0, find_shared_size(bin1, bin2))
  end

  defp find_shared_size(<<next, rest1::binary>>, <<next, rest2::binary>>) do
    1 + find_shared_size(rest1, rest2)
  end

  defp find_shared_size(_, _), do: 0
end
