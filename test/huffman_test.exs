defmodule HuffmanTest do
  use ExUnit.Case
  doctest Huffman

  test "compresses 'mississippi river rafting' correctly" do
    original_text = "mississippi river rafting"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses '' correctly" do
    original_text = ""
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses 'a' correctly" do
    original_text = "a"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses 'aa' correctly" do
    original_text = "aa"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses 'aaa' correctly" do
    original_text = "aaa"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses 'abcd' correctly" do
    original_text = "abcd"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses special characters correctly" do
    original_text = "¡™£¢§¶•ªº•˚˙£ß∆™¥£´ª"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end
end
