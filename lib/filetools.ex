require IEx
defmodule Huffman.FileTools do
  @moduledoc """
  Functions for reading and writing files.
  """

  def serialize(mapping) do
    #43abc42abc31320
    mapping
    |> Map.to_list # TODO maybe could be list in first place?
    |> Enum.reduce("", fn({width, mappings}, acc) ->
      symbols = Map.values(mappings)

      acc <> to_string(length(symbols) + 1) <> to_string(width) <> to_string(symbols)
    end)
  end

  defp create_group(bit_length, symbols) do
    mappings =
      symbols
      |> String.graphemes
      |> Enum.reduce(%{}, fn(character, mapping) ->
        Map.put(mapping, character, character)
      end)

    %{bit_length => mappings}
  end

  def deserialize(<<48, remaining::binary>>, m), do: {remaining, Huffman.Decoder.prep_map_for_decoding(Huffman.Encoder.assign_ascending_bits(Enum.reverse(m), 0))}

  def deserialize(<<first::binary-size(1), remaining::binary>>, m) do
    number_of_bytes_to_read = String.to_integer(first)
    <<x::binary-size(number_of_bytes_to_read), y::binary>> = remaining
    <<bit_length::binary-size(1), z::binary >> = x

    # [[{" ", 2}], [{"a", 3}, {"l", 3}, {"m", 3}], [{"e", 4}, {"s", 4}, {"t", 4}],
    wow =
      z
      |> String.graphemes
      |> Enum.map(fn symb -> {symb, String.to_integer(bit_length)} end)

      #group_mapping = create_group(String.to_integer(bit_length), z)
    deserialize(y, [wow | m])
  end

  defp ensure_binary(bits) when is_binary(bits), do: bits
  defp ensure_binary(bits), do: ensure_binary(<< bits::bitstring, <<0::1>> >>)

  defp read_file(path) do
    case File.read(path) do
      {:ok, text} -> Huffman.compress(text)
      {:error, reason} -> "Unable to read file: #{reason}"
    end
  end

  defp write_file({compressed_bits, mapping}, path) do
    final_data = << serialize(mapping)::binary, <<48>>, ensure_binary(compressed_bits)::binary >>

    case File.write(path, final_data) do # TODO also write header
      :ok -> "Compressed data: #{path}"
      {:error, reason} -> "Unable to write compressed data: #{reason}"
    end
  end

  @doc """
  Read and compress the text file found at given path.
  """
  def compress(path, out_file_path \\ nil) do
    path
    |> read_file
    |> write_file(out_file_path)
  end

  @doc """
  Decompress the file found at given path.
  """
  def decompress(path, out_file_path \\ nil) do
    case File.read(path) do
      {:ok, compressed_data} ->
        {encoded_data, mapping} = deserialize(compressed_data, [])
        Huffman.decompress(encoded_data, mapping)
    end
  end
end
