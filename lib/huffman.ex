require IEx

defmodule Huffman do
  @moduledoc """
  Implementation of Huffman Coding algorithm for
  text compression and decompression.
  """

  def build_frequency_mapping(text) do
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

  defp sorted_nodes(nodes) do
    nodes
    |> Enum.sort_by(fn obj -> obj.freq end)
  end

  def build_huffman_tree([]), do: nil
  def build_huffman_tree([tree]), do: tree
  def build_huffman_tree([left, right]) do
    %{type: :node, character: nil, freq: left.freq + right.freq, left: left, right: right}
  end
  def build_huffman_tree(nodes) do
    [first_smallest, second_smallest|rest] = sorted_nodes(nodes) # TODO this is not very optimal

    parent = %{
      type: :node,
      character: nil,
      freq: first_smallest.freq + second_smallest.freq,
      left: first_smallest,
      right: second_smallest
    }

    build_huffman_tree([parent|rest])
  end

  defp decode_helper(<< <<0::1>>, rest::bitstring >>, %{type: :node, freq: _, character: _, left: left, right: _}) do
    decode_helper(rest, left)
  end
  defp decode_helper(<< <<1::1>>, rest::bitstring >>, %{type: :node, freq: _, character: _, left: _, right: right}) do
    decode_helper(rest, right)
  end
  defp decode_helper(<<>>, tree) do
    {<<>>, tree.character}
  end
  defp decode_helper(encoded_bits, %{type: :leaf, character: character, freq: _freq}) do
    {encoded_bits, character}
  end

  defp decode(<<>>, _tree, decoded_text), do: decoded_text
  defp decode(<< <<_::1>>, rest::bitstring >>, %{type: :leaf, character: c, freq: _freq} = leaf, decoded_text), do: decode(rest, leaf, decoded_text <> c)
  defp decode(encoded_bits, tree, decoded_text) do
    case decode_helper(encoded_bits, tree) do
      {<<>>, decoded_character} ->
       	decoded_text <> decoded_character
      {encoded_bits, decoded_character} ->
        decode(encoded_bits, tree, decoded_text <> decoded_character)
    end
  end

  defp encode(huffman_mapping, text) do
    text
    |> String.graphemes
    |> Enum.reduce(<<>>, fn(letter, bits) ->
      << bits::bitstring, Enum.find(huffman_mapping, fn obj -> obj.character == letter end).encoding::bitstring >>
    end)
  end

  defp decorate_tree(%{type: :node, left: left_child, right: right_child, character: _, freq: _}, bits) do
    [decorate_tree(left_child, << bits::bitstring, <<0::1>> >>),
     decorate_tree(right_child, << bits::bitstring, <<1::1>> >>)]
  end
  defp decorate_tree(%{type: :leaf, character: character, freq: _}, <<>>) do
    [%{character: character, encoding: <<1::1>>}]
  end
  defp decorate_tree(%{type: :leaf, character: character, freq: _}, bits) do
    [%{character: character, encoding: bits}]
  end
  defp decorate_tree(nil, <<>>), do: []

  defp encode_graphemes(tree) do
    decorate_tree(tree, <<>>)
    |> List.flatten
  end

  @doc """
  Compress text using Huffman Coding algorithm

  ## Examples

      iex> Huffman.compress("aaabbbccc")
      {<<1, 47::size(7)>>,
       %{character: nil, freq: 9,
         left: %{character: nil, freq: 6,
           left: %{character: "a", freq: 3, type: :leaf},
           right: %{character: "b", freq: 3, type: :leaf}, type: :node},
         right: %{character: "c", freq: 3, type: :leaf}, type: :node}}

  """
  def compress(text) do
    tree = text
      |> build_frequency_mapping
      |> build_huffman_tree

    {tree
     |> encode_graphemes
     |> encode(text),
     tree}
  end

  @doc """
  Decompress encoded binary data to a string of text

  ## Examples

      iex> Huffman.decompress(<<13::size(6)>>, %{character: nil, freq: 4, left: %{character: nil, freq: 2, left: %{character: "b", freq: 1, type: :leaf}, right: %{character: "t", freq: 1, type: :leaf}, type: :node}, right: %{character: "o", freq: 2, type: :leaf}, type: :node})
      "boot"

  """
  def decompress(binary_data, tree) do
    binary_data
    |> decode(tree, "")
  end
end
