defmodule HuffmanFile do
  @moduledoc """
  File function
  """

  defp ensure_binary(bitz) when is_binary(bitz), do: bitz
  defp ensure_binary(bitz), do: ensure_binary(<< bitz::bitstring, <<0::1>> >>)

  def compress(path, text) do
    {bits, _tree} = Huffman.compress(text)
    bytes = ensure_binary(bits)

    case File.write(path, bytes) do
      :ok ->
        "Compression complete!"
      {:error, reason} ->
        "Text compression failed: #{reason}"
    end
  end

  def decompress(path) do
    # TODO
  end
end
