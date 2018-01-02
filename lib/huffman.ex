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
      [%{t: :l, c: List.first(chunk), f: length(chunk)}|acc]
    end)
    |> Enum.reverse
  end

  defp sorted_nodes(nodes) do
    nodes
    |> Enum.sort_by(fn obj -> obj.f end)
  end

  def build_huffman_tree([]), do: nil
  def build_huffman_tree([tree]), do: tree
  def build_huffman_tree([left, right]) do
    %{t: :n, c: nil, f: left.f + right.f, l: left, r: right}
  end
  def build_huffman_tree(nodes) do
    [first_smallest, second_smallest|rest] = sorted_nodes(nodes) # TODO this is not very optimal

    parent = %{
      t: :n,
      c: nil,
      f: first_smallest.f + second_smallest.f,
      l: first_smallest,
      r: second_smallest
    }

    build_huffman_tree([parent|rest])
  end

  defp decode_helper(<< <<0::1>>, rest::bitstring >>, %{t: :n, f: _, c: _, l: left, r: _}) do
    decode_helper(rest, left)
  end
  defp decode_helper(<< <<1::1>>, rest::bitstring >>, %{t: :n, f: _, c: _, l: _, r: right}) do
    decode_helper(rest, right)
  end
  defp decode_helper(<<>>, tree) do
    {<<>>, tree.c}
  end
  defp decode_helper(encoded_bits, %{t: :l, c: character, f: _freq}) do
    {encoded_bits, character}
  end

  defp decode(<<>>, _tree, decoded_text), do: decoded_text
  defp decode(<< <<_::1>>, rest::bitstring >>, %{t: :l, c: c, f: _freq} = leaf, decoded_text), do: decode(rest, leaf, decoded_text <> c)
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
      << bits::bitstring, Enum.find(huffman_mapping, fn obj -> obj.c == letter end).e::bitstring >>
    end)
  end

  defp decorate_tree(%{t: :n, l: left_child, r: right_child, c: _, f: _}, bits) do
    [decorate_tree(left_child, << bits::bitstring, <<0::1>> >>),
     decorate_tree(right_child, << bits::bitstring, <<1::1>> >>)]
  end
  defp decorate_tree(%{t: :l, c: character, f: _}, <<>>) do
    [%{c: character, e: <<1::1>>}]
  end
  defp decorate_tree(%{t: :l, c: character, f: _}, bits) do
    [%{c: character, e: bits}]
  end
  defp decorate_tree(nil, <<>>), do: []

  defp encode_graphemes(tree) do
    decorate_tree(tree, <<>>)
    |> List.flatten
  end

  @doc """
  Compress text using Huffman Coding algorithm

  For the Huffman Tree I used the smallest possible key names in order
  to save as many bits as possible when doing `:erlang.term_to_binary`

  c --> character
  f --> frequency
  l --> left
  r --> right
  t --> type (:node or :leaf)

  ## Examples

      iex> Huffman.compress("aaabbbccc")
      {<<1, 47::size(7)>>,
       %{c: nil, f: 9,
         l: %{c: nil, f: 6,
           l: %{c: "a", f: 3, t: :l},
           r: %{c: "b", f: 3, t: :l}, t: :n},
         r: %{c: "c", f: 3, t: :l}, t: :n}}

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

      iex> Huffman.decompress(<<13::size(6)>>, %{c: nil, f: 4, l: %{c: nil, f: 2, l: %{c: "b", f: 1, t: :l}, r: %{c: "t", f: 1, t: :l}, t: :n}, r: %{c: "o", f: 2, t: :l}, t: :n})
      "boot"

  """
  def decompress(binary_data, tree) do
    binary_data
    |> decode(tree, "")
  end
end
