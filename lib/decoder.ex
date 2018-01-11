defmodule Huffman.Decoder do
  @moduledoc """
  Implementation of Huffman Coding algorithm
  for text decompression.
  """

  defp get_encoded_character(bits, map) do
    map[bits]
  end

  defp process_bits(bits, maps, key) do
    << <<b::size(key)>>, remaining::bitstring >> = bits

    case get_encoded_character(<<b::size(key)>>, maps[key]) do
      nil -> process_bits(bits, maps, key - 1)
      decoded_character -> {decoded_character, remaining}
    end
  end

  @doc """
  """
  def decode(<<>>, _maps, _bit_length, decoded_symbols), do: decoded_symbols

  def decode(encoded_bits, maps, bit_length, decoded_symbols) do
    {next_character, next_bits} =
      encoded_bits
      |> process_bits(maps, bit_length)

    next_bit_length =
      bit_size(next_bits)
      |> min(bit_length)

    decode(next_bits, maps, next_bit_length, decoded_symbols <> next_character)
  end

  @doc """
  """
  def prep_map_for_decoding(mappings) do
    mappings
    |> Enum.to_list
    |> Enum.sort_by(fn ({_, encoding}) -> bit_size(encoding) end)
    |> Enum.chunk_by(fn ({_, encoding}) -> bit_size(encoding) end)
    |> Enum.reduce(%{}, fn (encodings, map) ->
      sub_map =
        encodings
        |> Map.new(fn({symbol, encoding}) -> {encoding, symbol} end)

      [{_, first_encoding} | _] = encodings

      map
      |> Map.put(bit_size(first_encoding), sub_map)
    end)
  end
end
