defmodule Huffman do
  @moduledoc """
  Implementation of Huffman Coding algorithm for
  text compression and decompression.
  """

  defp calculate_frequencies(text) do
    text
    |> String.graphemes
    |> Enum.sort
    |> Enum.chunk_by(fn arg -> arg end)
    |> Enum.sort_by(&length/1)
    |> Enum.reduce([], fn(chunk, acc) ->
      [%{character: List.first(chunk), freq: length(chunk)}|acc]
    end)
  end

  defp insert_if_has_character(heap, %{freq: _, character: nil}) do
    heap
  end
  defp insert_if_has_character(heap, %{freq: _, character: _} = child) do
    MinHeap.insert(heap, child)
  end

  defp build_heap([], heap), do: heap
  defp build_heap([child], heap) do
    heap
    |> insert_if_has_character(child)
  end
  defp build_heap([left, right|tail], heap) do
    parent = %{
      freq: left.freq + right.freq,
      character: nil
    }

    new_heap = MinHeap.insert(heap, parent)
               |> insert_if_has_character(left)
               |> insert_if_has_character(right)
    build_heap([parent|tail], new_heap)
  end

  defp encode_at_index(index, binary_string) when index < 2 do
    binary_string
  end
  defp encode_at_index(index, binary_string) when rem(index, 2) == 1 do
    div(index, 2)
    |> encode_at_index("1" <> binary_string)
  end
  defp encode_at_index(index, binary_string) when rem(index, 2) == 0 do
    div(index, 2)
    |> encode_at_index("0" <> binary_string)
  end

  defp encode(heap, text) do
    encode_reference = heap |> Enum.map(fn(obj) -> obj.character end)

    binary_encoding = text
    |> String.graphemes
    |> Enum.reduce("", fn(letter, acc) ->
      encoded_letter = encode_reference
                       |> Enum.find_index(fn(x)-> x == letter end)
                       |> encode_at_index("")
      acc <> encoded_letter
    end)
    {binary_encoding, encode_reference} # should it be heap? not sure yet
  end

  defp decode_bit(bits, index, heap) do
    # TODO eww
    case Enum.at(heap, index) do
      nil ->
        case String.first(bits) do
          "0" ->
            decode_bit(String.slice(bits, 1..-1), (index * 2), heap)
          "1" ->
            decode_bit(String.slice(bits, 1..-1), (index * 2) + 1, heap)
        end
      letter ->
        {letter, bits}
    end
  end

  defp decode(binary_data, heap) do
    {letter, bits} = decode_bit(binary_data, 1, heap)
    decode(bits, heap, letter)
  end
  defp decode("", _, letters), do: letters
  defp decode(binary_data, heap, letters) do
    {letter, bits} = decode_bit(binary_data, 1, heap)
    decode(bits, heap, letters <> letter)
  end

  @doc """
  Compress text using Huffman Coding algorithm

  ## Examples

      iex> Huffman.compress("aaabbbccc")
      {"010101111000000", [nil, nil, nil, "b", "c", "a"]}

  """
  def compress(text) do
    text
    |> calculate_frequencies
    |> build_heap([])
    |> encode(text)
  end

  @doc """
  Decompress encoded binary data to a string of text

  ## Examples

      iex> Huffman.decompress("0100001", [nil, nil, nil, "t", "o", "b"])
      "boot"

  """
  def decompress(binary_data, heap) do
    binary_data
    |> decode(heap)
  end
end
