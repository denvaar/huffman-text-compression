require IEx

defmodule Huffman do
  @moduledoc """
  Implementation of Huffman Coding algorithm for
  text compression and decompression.
  """

  use Bitwise

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

  defp sorted_nodes(nodes) do
    nodes
    |> Enum.sort_by(fn obj -> obj.freq end)
  end

  defp build_huffman_tree([]), do: nil
  defp build_huffman_tree([tree]), do: tree
  defp build_huffman_tree([left, right]) do
    %{type: :node, character: nil, freq: left.freq + right.freq, left: left, right: right}
  end
  defp build_huffman_tree(nodes) do
    [first_smallest, second_smallest | rest] = sorted_nodes(nodes) # OPTIMIZE

    parent = %{
      type: :node,
      character: nil,
      freq: first_smallest.freq + second_smallest.freq,
      left: first_smallest,
      right: second_smallest
    }

    build_huffman_tree([parent | rest])
  end

  defp get_encoded_character(bits, map) do
    map[bits]
  end

  defp process_bits(bits, maps, key) do
    << <<b::size(key)>>, remaining::bitstring >> = bits
    IO.inspect({b, key, bits})

    case get_encoded_character(<<b::size(key)>>, maps[key]) do
      nil -> process_bits(bits, maps, key - 1)
      decoded_character -> {decoded_character, remaining}
    end
  end

  defp decode_from_maps(<<>>, _maps, _max_bit_length), do: ""
  defp decode_from_maps(encoded_bits, maps, max_bit_length) do
    {next_character, next_bits} =
      encoded_bits
      |> process_bits(maps, max_bit_length)

    next_bit_length =
      bit_size(next_bits)
      |> min(max_bit_length)

    next_character <> decode_from_maps(next_bits, maps, next_bit_length)
  end

  defp encode(huffman_mapping, text) do
    text
    |> String.graphemes
    |> Enum.reduce(<<>>, fn(letter, bits) ->
      << bits::bitstring, (huffman_mapping[letter])::bitstring >>
    end)
  end

  # defp decorate_tree(%{type: :node, left: left_child, right: right_child}, bits) do
  #   [decorate_tree(left_child, << bits::bitstring, <<0::1>> >>),
  #    decorate_tree(right_child, << bits::bitstring, <<1::1>> >>)]
  # end
  # defp decorate_tree(%{type: :leaf, character: character}, bits), do: [%{character: character, encoding: bits}]
  # defp decorate_tree(nil, <<>>), do: []

  defp mapping_from_tree(nil, _), do: %{}
  defp mapping_from_tree(%{type: :node, left: left_child, right: right_child}, bits) do
    mapping_from_tree(left_child, bits + 1)
    |> Map.merge(mapping_from_tree(right_child, bits + 1))
  end
  defp mapping_from_tree(%{type: :leaf, character: character}, bits), do: %{character => bits}

  defp encode_graphemes(tree) do
    tree
    |> mapping_from_tree(0)
    #|> decorate_tree(<<>>)
    #|> List.flatten
  end

  defp create_canonical_mapping(mapping) do
    mapping
    |> Enum.chunk_by(fn obj -> obj.encoding end)
    |> Enum.reduce("", fn (obj, acc) ->
      [first | _rest] = obj
      to_string(first.encoding) <> to_string(Enum.map(obj, fn(o) -> o.character end)) <> acc
    end)
  end

  defp huffman_tree(text) do
    text
    |> build_frequency_mapping
    |> build_huffman_tree
  end

  # defp inc([], output, _number_of_bits, bit_value), do: {output, bit_value}
  # defp inc([obj|rest], output, number_of_bits, bit_value) do
  #   new_array = [%{character: obj.character, encoding: <<(bit_value)::size(number_of_bits)>>} | output]
  #   inc(rest, new_array, number_of_bits, bit_value + 1)
  # end

  # defp increment_bits([], _bit_value, new), do: new
  # defp increment_bits([first | rest], bit_value, new) do
  #   [first_obj | _] = first
  #   number_of_bits = bit_size(first_obj.encoding)

  #   {n, bv} = inc(first, [], number_of_bits, bit_value)

  #   case rest do
  #     [] -> increment_bits(rest, bv <<< 1, [n | new])
  #     [[next | _] | _] -> increment_bits(rest, bv <<< (bit_size(next.encoding) - number_of_bits), [n | new])
  #   end
  # end

  defp assign_ascending_bits([mappings_with_same_widths, next_mappings | remaining_mappings], bit_value) do
    [{_, current_mapping_width} | _] = mappings_with_same_widths
    [{_, next_mapping_width} | _] = next_mappings

    map =
      (0..length(mappings_with_same_widths))
      |> Enum.zip(mappings_with_same_widths)
      |> Enum.reduce(%{}, fn({value, {symbol, width}}, acc) ->
        acc
        |> Map.put(symbol, <<(value + bit_value)::size(width)>>)
      end) # TODO separate this to common function

    assign_ascending_bits([next_mappings | remaining_mappings], (length(mappings_with_same_widths) + bit_value) <<< (next_mapping_width - current_mapping_width))
    |> Map.merge(map)
  end

  defp assign_ascending_bits([mappings_with_same_widths], bit_value) do
    [{_, current_mapping_width} | _] = mappings_with_same_widths

    (0..length(mappings_with_same_widths))
    |> Enum.zip(mappings_with_same_widths)
    |> Enum.reduce(%{}, fn({value, {symbol, width}}, acc) ->
      acc
      |> Map.put(symbol, <<(value + bit_value)::size(width)>>)
    end)
  end

  # defp rearrange_for_canonical_coding(mapping) do
  #   mapping
  #   |> Enum.sort_by(fn obj -> bit_size(obj.encoding) end)
  #   |> Enum.reverse
  #   |> Enum.chunk_by(fn obj -> bit_size(obj.encoding) end)
  #   |> Enum.reduce([], fn(set, acc) ->
  #     [Enum.sort_by(set, fn obj -> obj.character end)|acc]
  #   end)
  #   |> increment_bits(0, [])
  # end

  def func(mapping) do
    mapping
    |> Map.to_list
    |> Enum.sort_by(fn({_, f}) -> f end)
    |> Enum.chunk_by(fn({_,f}) -> f end)
    |> Enum.map(fn(s) ->
      Enum.sort_by(s, fn({c, _}) -> c end)
    end)
    |> assign_ascending_bits(0)
  end

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

  @doc """
  Compress text using Huffman Coding algorithm

  ## Examples

      iex> Huffman.compress("mississippi river rafting")

  """
  def compress(text) do
    canonical_mappings =
      text
      |> huffman_tree
      |> encode_graphemes
      |> func# |> rearrange_for_canonical_coding

    IO.inspect(canonical_mappings)

    compressed_text =
      canonical_mappings
      |> encode(text)

    {compressed_text, prep_map_for_decoding(canonical_mappings)}
  end

  @doc """
  Decompress encoded binary data to a string of text

  ## Examples

  """
  def decompress(<<>>, _), do: ""
  def decompress(encoded_data, mappings) do
    max_bit_length =
      mappings
      |> Map.keys
      |> Enum.max

    encoded_data
    |> decode_from_maps(mappings, max_bit_length)
  end
end
