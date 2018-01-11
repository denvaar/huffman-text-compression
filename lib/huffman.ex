defmodule Huffman do
  @moduledoc """
  Implementation of Huffman Coding algorithm for
  text compression and decompression.
  """

  alias Huffman.Encoder
  alias Huffman.Decoder

  @doc """
  Compress text by using Huffman Coding algorithm.

  ## Examples

    iex> Huffman.compress("dad")
    {<<5::size(3)>>, %{1 => %{<<0::size(1)>> => "a", <<1::size(1)>> => "d"}}}

    iex> Huffman.compress("rats")
    {"N", %{2 => %{<<0::size(2)>> => "a", <<1::size(2)>> => "r", <<2::size(2)>> => "s", <<3::size(2)>> => "t"}}}

  """
  def compress(text) do
    canonical_mappings =
      text
      |> Encoder.huffman_tree
      |> Encoder.encode_graphemes
      |> Encoder.generate_canonical_mapping

    compressed_text =
      canonical_mappings
      |> Encoder.encode(text)

    {compressed_text, Decoder.prep_map_for_decoding(canonical_mappings)}
  end

  @doc """
  Decompress encoded binary data to a string of text.

  ## Examples

    iex> Huffman.decompress(<<209, 23, 30::size(5)>>, %{1 => %{<<0::size(1)>> => "s"}, 2 => %{<<2::size(2)>> => "i"}, 3 => %{<<6::size(3)>> => "m", <<7::size(3)>> => "p"}})
    "mississippi"

  """
  def decompress(<<>>, _), do: ""

  def decompress(encoded_data, mappings) do
    max_bit_length =
      mappings
      |> Map.keys
      |> Enum.max

    Decoder.decode(encoded_data, mappings, max_bit_length, <<>>)
  end
end
