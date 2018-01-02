require IEx
defmodule HuffmanFile do
  @moduledoc """
  File function
  """

  defp ensure_binary(bits) when is_binary(bits), do: bits
  defp ensure_binary(bits), do: ensure_binary(<< bits::bitstring, <<0::1>> >>)

  defp serialize_huffman_tree(tree), do: :erlang.term_to_binary(tree)

  defp deserialize_huffman_tree(bytes), do: :erlang.binary_to_term(bytes)

  def compress(path, text) do
    {bits, tree} = Huffman.compress(text)
    serialized_tree = serialize_huffman_tree(tree)

    case File.write(path, to_string(byte_size(serialized_tree)) <> "|" <> serialized_tree <> ensure_binary(bits)) do
      :ok ->
        "Compression complete!"
      {:error, reason} ->
        "Text compression failed: #{reason}"
    end
  end

  defp chomp_size(<<digit::size(8)>> <> rest) do
    case <<digit>> do
      "|" ->
        {"", rest}
      _anything_else ->
        {size, remaining_bytes} = chomp_size(rest)
        {<<digit>> <> size, remaining_bytes}
    end
  end

  def decompress(path) do
    case File.read(path) do
      {:ok, encoded_content} ->
        {size_of_tree, remaining_content} = chomp_size(encoded_content)
        sz = String.to_integer(size_of_tree)
        << tree_bytes::binary-size(sz), rest::binary >> = remaining_content
        huffman_tree = deserialize_huffman_tree(tree_bytes)
        Huffman.decompress(rest, huffman_tree)
      {:error, reason} ->
        "Unable to decompress file: #{reason}"
    end
  end
end
