defmodule HuffmanTest do
  use ExUnit.Case
  doctest Huffman

  test "compresses and decompresses text correctly" do
    original_text = "mississippi river rafting"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end
end
