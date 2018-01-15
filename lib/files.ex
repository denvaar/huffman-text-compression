require IEx
defmodule Huffman.Files do
  @moduledoc """
  Functions for reading and writing files.
  """

  defp width_from_classifier(character) do
    case character do
      "a" -> 1
      "b" -> 2
      "c" -> 3
      "d" -> 4
      "f" -> 5
    end
  end

  defp classifier_from_width(width) do
    case width do
      1 -> "a"
      2 -> "b"
      3 -> "c"
      4 -> "d"
      5 -> "f"
    end
  end

  defp serialize_number_of_bytes_to_read_next(symbols, max_width) do
    symbols
    |> Enum.map(fn symbol -> byte_size(symbol) end)
    |> Enum.sum()
    |> to_string()
    |> String.pad_leading(max_width, "0")
  end

  defp serialize_group_size_number(width, max_width) do
    width
    |> to_string()
    |> String.pad_leading(max_width, "0")
  end

  def serialize(mapping) do
    max_bytes_to_read_width =
      mapping
      |> Map.values()
      |> Enum.map(fn mapping -> Map.values(mapping) end)
      |> Enum.map(fn list ->
        Enum.map(list, fn character -> byte_size(character) end)
      end)
      |> Enum.map(fn value -> Enum.sum(value) end)
      |> Enum.max()
      |> Integer.digits()
      |> length()

    max_group_width =
      mapping
      |> Map.keys()
      |> Enum.max()
      |> Integer.digits()
      |> length()

    initial_text = "#{classifier_from_width(max_bytes_to_read_width)}#{classifier_from_width(max_group_width)}"

    mapping
    |> Map.to_list()
    |> Enum.reduce(initial_text, fn({width, mappings}, acc) ->
      symbols = Map.values(mappings)

      acc \
      <> serialize_number_of_bytes_to_read_next(symbols, max_bytes_to_read_width) \
      <> serialize_group_size_number(width, max_group_width) \
      <> to_string(symbols)
    end)
  end


  def deserialize(<<48, 32, remaining::bitstring>>, _to_read_width, _group_width, m) do
    {remaining, Huffman.Decoder.prep_map_for_decoding(Huffman.Encoder.assign_ascending_bits(Enum.reverse(m), 0))}
  end

  def deserialize(header, to_read_width, group_width, m) do
    <<first::binary-size(to_read_width), second::binary-size(group_width), remaining::bitstring>> = header
    number_of_bytes_to_read = String.to_integer(first)
    bit_length = String.to_integer(second)
    <<bytes_for_group::binary-size(number_of_bytes_to_read), y::bitstring>> = remaining

    wow =
      bytes_for_group
      |> IO.inspect()
      |> String.graphemes()
      |> Enum.map(fn symb -> {symb, bit_length} end)

    IO.inspect(wow)

    deserialize(y, to_read_width, group_width, [wow | m])
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
    number_of_junk_bits = to_string(bit_size(ensure_binary(compressed_bits)) - bit_size(compressed_bits))
    final_data = << number_of_junk_bits::binary, serialize(mapping)::binary, <<48, 32>>, ensure_binary(compressed_bits)::binary >>

    IO.inspect(serialize(mapping))

    case File.write(path, final_data) do
      :ok -> "Data written to -> #{path}"
      {:error, reason} -> "Unable to write compressed data: #{reason}"
    end
  end

  defp write_file(uncompressed_text, path) do
    case File.write(path, uncompressed_text) do
      :ok -> "File decompression complete #{path}"
      {:error, reason} -> "Unable to decompress data: #{path}"
    end
  end

  @doc """
  Read and compress the text file found at given path.
  """
  def compress(path, out_file_path \\ nil) do
    path
    |> read_file()
    |> write_file(out_file_path)
  end

  @doc """
  Decompress the file found at given path.
  """
  def decompress(path, out_file_path \\ nil) do
    case File.read(path) do
      {:ok, <<number_of_leftover_bits::binary-size(1), first::binary-size(1), second::binary-size(1), compressed_data::binary>>} ->
        bytes_to_read_width = width_from_classifier(first)
        group_size_width = width_from_classifier(second)

        bit_diff = bit_size(compressed_data) - String.to_integer(number_of_leftover_bits)
        <<cd::size(bit_diff), _junk_bits::bitstring>> = compressed_data

        {encoded_data, mapping} = deserialize(<<cd::size(bit_diff)>>, bytes_to_read_width, group_size_width, [])
        Huffman.decompress(encoded_data, mapping)
        |> write_file(out_file_path)

      {:error, reason} -> "Unable to read input file"
    end
  end
end
