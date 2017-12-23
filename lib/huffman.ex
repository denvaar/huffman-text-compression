defmodule Huffman do
  @moduledoc """
  Implementation of Huffman Coding algorithm for
  text compression and decompression.
  """

  defp build_frequency_mapping(text) do
    text
    |> String.graphemes
    |> Enum.sort
    |> Enum.chunk_by(fn arg -> arg end)
    |> Enum.sort_by(&length/1)
    |> Enum.reduce([], fn(chunk, acc) ->
      [%{character: List.first(chunk), freq: length(chunk)}|acc]
    end)
  end

  defp insert_if_has_character(heap, %{freq: _, character: nil}), do: heap
  defp insert_if_has_character(heap, %{freq: _, character: _} = child), do: MinHeap.insert(heap, child)

  defp insert_subtree(heap, left, right) do
    heap
    |> MinHeap.insert(parent_node(left, right))
    |> insert_if_has_character(left)
    |> insert_if_has_character(right)
  end

  defp parent_node(left, right), do: %{freq: left.freq + right.freq, character: nil}

  defp build_heap([], heap), do: heap
  defp build_heap([child], heap),do: insert_if_has_character(heap, child)
  defp build_heap([left, right|tail], heap), do: build_heap([parent_node(left, right)|tail], insert_subtree(heap, left, right))

  defp encode_at_index(index, binary_string) when index < 2, do: binary_string
  defp encode_at_index(index, binary_string) when rem(index, 2) == 1 do
    div(index, 2)
    |> encode_at_index(<< <<1::1>>, binary_string::bitstring >>)
  end
  defp encode_at_index(index, binary_string) when rem(index, 2) == 0 do
    div(index, 2)
    |> encode_at_index(<< <<0::1>>, binary_string::bitstring >>)
  end

  defp encode(heap, text) do
    encode_reference = Enum.map(heap, fn(obj) -> obj.character end)

    binary_encoding = text
    |> String.graphemes
    |> Enum.reduce(<<>>, fn(letter, acc) ->
      encoded_letter = encode_reference
                       |> Enum.find_index(fn(x)-> x == letter end)
                       |> encode_at_index(<<>>)
      << acc::bitstring, encoded_letter::bitstring >>
    end)
    {binary_encoding, encode_reference}
  end

  defp visit_heap_node_at(heap, index), do: Enum.at(heap, index)

  defp process_heap_node(nil, << first_bit::1, _rest::bitstring >>), do: first_bit
  defp process_heap_node(letter, bits), do: {letter, bits}

  defp stop_if_leaf_node(0, << _::1, rest::bitstring >>, index, heap), do: walk_down_heap(rest, (index * 2), heap)
  defp stop_if_leaf_node(1, << _::1, rest::bitstring >>, index, heap), do: walk_down_heap(rest, (index * 2) + 1, heap)
  defp stop_if_leaf_node({letter, bits}, _, _, _), do: {letter, bits}

  defp walk_down_heap(bits, index, heap) do
    heap
    |> visit_heap_node_at(index)
    |> process_heap_node(bits)
    |> stop_if_leaf_node(bits, index, heap)
  end

  defp decode(binary_data, heap) do
    {letter, bits} = walk_down_heap(binary_data, 1, heap)
    decode(bits, heap, letter)
  end

  defp decode(<<>>, _, letters), do: letters
  defp decode(binary_data, heap, letters) do
    {letter, bits} = walk_down_heap(binary_data, 1, heap)
    decode(bits, heap, letters <> letter)
  end

  @doc """
  Compress text using Huffman Coding algorithm

  ## Examples

      iex> Huffman.compress("aaabbbccc")
      {<<87, 64::size(7)>>, [nil, nil, nil, "b", "c", "a"]}

  """
  def compress(text) do
    text
    |> build_frequency_mapping
    |> build_heap([])
    |> encode(text)
  end

  @doc """
  Decompress encoded binary data to a string of text

  ## Examples

      iex> Huffman.decompress(<<33::size(7)>>, [nil, nil, nil, "t", "o", "b"])
      "boot"

  """
  def decompress(binary_data, heap) do
    binary_data
    |> decode(heap)
  end
end
