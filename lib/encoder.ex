defmodule Huffman.Encoder do
  @moduledoc """
  Implementation of Huffman Coding algorithm
  for text compression.
  """

  use Bitwise

  defp encoding_for_group(group, bit_value_offset, group_length) do
    (0..group_length)
    |> Enum.zip(group)
    |> Enum.reduce(%{}, fn({value, {symbol, width}}, acc) ->
      acc
      |> Map.put(symbol, <<(value + bit_value_offset)::size(width)>>)
    end)
  end

  defp bit_width([{_, width} | _]), do: width

  defp assign_ascending_bits([], _bit_value), do: %{}

  defp assign_ascending_bits([group], bit_value),
    do: encoding_for_group(group, bit_value, length(group))

  defp assign_ascending_bits([current_group, next_group | remaining_mappings], bit_value) do
    group_length = length(current_group)
    left_shift_amount = bit_width(next_group) - bit_width(current_group)
    next_value = (group_length + bit_value) <<< left_shift_amount
    next_group_encoding = assign_ascending_bits([next_group | remaining_mappings], next_value)

    Map.merge(next_group_encoding, encoding_for_group(current_group, bit_value, group_length))
  end

  @doc """
  Produce a canonical Huffman code mapping.
  """
  def generate_canonical_mapping(mapping) do
    mapping
    |> Map.to_list
    |> Enum.sort_by(fn({_, f}) -> f end)
    |> Enum.chunk_by(fn({_,f}) -> f end)
    |> Enum.map(fn(s) ->
      Enum.sort_by(s, fn({c, _}) -> c end)
    end)
    |> assign_ascending_bits(0)
  end

  defp mapping_from_tree(nil, _), do: %{}
  defp mapping_from_tree(%{type: :leaf, character: character}, bits), do: %{character => bits}

  defp mapping_from_tree(%{type: :node, left: left_child, right: right_child}, bits),
    do: Map.merge(mapping_from_tree(left_child, bits + 1), mapping_from_tree(right_child, bits + 1))

  def encode_graphemes(tree), do: mapping_from_tree(tree, 0)

  defp sorted_nodes(nodes) do
    nodes
    |> Enum.sort_by(fn obj -> obj.freq end)
  end

  defp build_huffman_tree([]), do: nil
  defp build_huffman_tree([tree]),
    do: %{type: :node, character: nil, freq: tree.freq, left: tree, right: nil}

  defp build_huffman_tree([left, right]) do
    %{type: :node, character: nil, freq: left.freq + right.freq, left: left, right: right}
  end
  defp build_huffman_tree(nodes) do
    [first_smallest, second_smallest | rest] = sorted_nodes(nodes)

    parent = %{
      type: :node,
      character: nil,
      freq: first_smallest.freq + second_smallest.freq,
      left: first_smallest,
      right: second_smallest
    }

    build_huffman_tree([parent | rest])
  end

  defp build_frequency_mapping(text) do
    text
    |> String.graphemes
    |> Enum.sort
    |> Enum.chunk_by(fn arg -> arg end)
    |> Enum.sort_by(&length/1)
    |> Enum.reduce([], fn(chunk, acc) ->
      [%{type: :leaf, character: List.first(chunk), freq: length(chunk)}|acc]
    end)
    |> Enum.reverse
  end

  @doc """
  Build a huffman tree out of the provided text.
  """
  def huffman_tree(text) do
    text
    |> build_frequency_mapping
    |> build_huffman_tree
  end

  @doc """
  Encode text using a given mapping.

  Huffman.compress(text) is the main compression/encoding function.
  """
  def encode(huffman_mapping, text) do
    text
    |> String.graphemes
    |> Enum.reduce(<<>>, fn(letter, bits) ->
      << bits::bitstring, (huffman_mapping[letter])::bitstring >>
    end)
  end
end
