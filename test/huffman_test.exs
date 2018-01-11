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

  test "compresses alphabet correctly" do
    original_text = "Aa Bb Cc Dd Ee Ff Gg Hh Ii Jj Kk Ll Mm Nn Oo Pp Qq Rr Ss Tt Uu Vv Ww Xx Yy Zz"
    {encoded_data, heap} = Huffman.compress(original_text)

    assert Huffman.decompress(encoded_data, heap) == original_text
  end

  test "compresses text for the 27 Amendments correctly" do
    case File.read('./sample_text/amendments.txt') do
      {:ok, text} ->
        {encoded_data, mapping} = Huffman.compress(text)
        assert Huffman.decompress(encoded_data, mapping) == text

      {:error, _reason} ->
        ExUnit.Assertions.assert(false, "Trouble opening/reading the file.")
    end
  end

  test "compresses text for Beowulf epic poem correctly" do
    case File.read('./sample_text/beowulf.txt') do
      {:ok, text} ->
        {encoded_data, mapping} = Huffman.compress(text)
        assert Huffman.decompress(encoded_data, mapping) == text

      {:error, _reason} ->
        ExUnit.Assertions.assert(false, "Trouble opening/reading the file.")
    end
  end
end
