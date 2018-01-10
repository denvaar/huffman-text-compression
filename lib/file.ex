require IEx
defmodule HuffmanFile do
  @moduledoc """
  File function
  """

  # defp ensure_binary(bits) when is_binary(bits), do: bits
  # defp ensure_binary(bits), do: ensure_binary(<< bits::bitstring, <<0::1>> >>)

  # def compress(path, text) do
  #   {bits, huffman_tree} = Huffman.compress(text)
  #   serialized_huffman_tree = serialize(huffman_tree)

  #   serialized_huffman_tree
  #   |> byte_size
  #   |> get_table_size_category
  #   |> add_table_size(byte_size(serialized_huffman_tree))
  #   |> add_table(serialized_huffman_tree)
  #   |> add_encoded_data(bits)
  #   |> write_file(path)
  # end

  # def add_table_size(size_category, table_size) do
  #   size = table_size
  #          |> to_string
  #          |> String.pad_leading(number_of_bytes_used(size_category), <<0>>)
  #   << size_category::binary, size::binary >>
  # end

  # def add_table(metadata, serialized_huffman_tree) do
  #   << metadata::binary, serialized_huffman_tree::binary >>
  # end

  # def add_encoded_data(metadata, encoded_bits) do
  #   << metadata::binary, ensure_binary(encoded_bits)::binary >>
  # end

  # def write_file(encoded_data, path) do
  #   case File.write(path, encoded_data) do
  #     :ok ->
  #       "Compression completed!"
  #     {:error, reason} ->
  #       "Text compression failed: #{reason}"
  #   end
  # end

  # defp chomp_size(<<digit::size(8)>> <> rest) do
  #   case <<digit>> do
  #     "|" ->
  #       {"", rest}
  #     _anything_else ->
  #       {size, remaining_bytes} = chomp_size(rest)
  #       {<<digit>> <> size, remaining_bytes}
  #   end
  # end

  def serialize(mapping) do
    (mapping
      |> Enum.reduce("", fn(arr, acc) ->
        characters = arr
          |> Enum.map(fn obj -> obj.c end)
          |> Enum.reverse
          |> List.to_string

        acc <> to_string(length(arr)) <> characters
      end)) <> "0"

  end
  # def sersalize(nil), do: ";"
  # def serialize(%{t: :n, f: freq, r: right, l: left, c: _}) do
  #   [freq, serialize(left), serialize(right)]
  #   |> Enum.join(";")
  # end
  # def serialize(%{c: character, f: _, t: :l}) do
  #   character <> ";;"
  # end

  # def deserialize([next_character|remaining_characters]) do
  #   case Integer.parse(next_character) do
  #     :error ->
  #       :leaf
  #     {freq, ""} ->
  #       :node
  #   end
  # end

  # 13333 ednrv

  # "e1d3n3r3v3"
  # |> tree_from_canon(0)

  # v3r3n3d3e1 0
  # def tree_from_canon(<< symbol::binary-size(1), bit_length::binary-size(1), remaining::binary >>, 0) do
  #   %{type: :node, left: nil, right: %{type: :leaf, character: symbol}}
  #   |> tree_from_canon(remaining, 1)
  # end
  # def tree_from_canon(tree, <<>>, level) do

  # end

  # def tree_from_canon_helper(tree, << symbol::binary-size(1), bit_length::binary-size(1), remaining::binary >>, tree_level) when tree_level == bit_length do
  #   %{type: :node, left: %{type: :leaf, character: symbol}, right: tree}
  #   |> tree_from_canon_helper(remaining, bit_length)
  # end

  # def get_table_size_category(number_of_bytes) when number_of_bytes < 1000, do: "s" # no more than 3 digits long
  # def get_table_size_category(number_of_bytes) when number_of_bytes < 10000, do: "m" # no more than 4 digits long
  # def get_table_size_category(number_of_bytes) when number_of_bytes < 100000, do: "l" # no more than 5 digits long
  # def get_table_size_category(number_of_bytes), do: raise "Error: This program did not expect to handle so much data."

  # # number of bytes needed to store the size of the huffman tree in the file.
  # def number_of_bytes_used("s"), do: 3
  # def number_of_bytes_used("m"), do: 4
  # def number_of_bytes_used("l"), do: 5

  # def read_huffman_tree_size(<< 0, rest::binary >>), do: read_huffman_tree_size(rest)
  # def read_huffman_tree_size(size), do: size

  # def read_one_byte(<< first_byte::binary-size(1), _remaining_bytes::binary >>), do: first_byte

  # def read_huffman_tree(size_in_bytes, encoded_content) do
  #   << _size_category::binary-size(1), bytes_for_tree_size::binary-size(size_in_bytes), rest::binary >> = encoded_content
  #   tree_size = read_huffman_tree_size(bytes_for_tree_size)
  #               |> String.to_integer
  #   << huffman_tree::binary-size(tree_size), encoded_bytes::binary >> = rest

  #   {deserialize(huffman_tree), encoded_bytes}
  # end

  # def decompress(path) do
  #   case File.read(path) do
  #     {:ok, encoded_content} ->
  #       {huffman_tree, data} = encoded_content
  #                              |> read_one_byte
  #                              |> number_of_bytes_used
  #                              |> read_huffman_tree(encoded_content)
  #       Huffman.decompress(data, huffman_tree)
  #       # {size_of_tree, remaining_content} = chomp_size(encoded_content)
  #       # sz = String.to_integer(size_of_tree)
  #       # << tree_bytes::binary-size(sz), rest::binary >> = remaining_content
  #       # huffman_tree = deserialize_huffman_tree(tree_bytes)
  #       # Huffman.decompress(rest, huffman_tree)
  #     {:error, reason} ->
  #       "Unable to decompress file: #{reason}"
  #   end
  # end
end
