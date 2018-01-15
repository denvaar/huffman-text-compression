defmodule Huffman.FilesTest do
  use ExUnit.Case
  alias Huffman.Files

  doctest Huffman.Files

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} -> content
      {:error, _reason} -> ""
    end
  end

  defp test_file(original_file) do
    compressed_file = './out.txt.huff'
    uncompressed_file = './out.txt'

    Files.compress(original_file, compressed_file)
    Files.decompress(compressed_file, uncompressed_file)

    assert read_file(uncompressed_file) == read_file(original_file)
  end

  test "compress/decompress test.txt" do
    test_file("./sample_text/test.txt")
  end

  test "compress/decompress crazy_characters.txt" do
    test_file("./sample_text/crazy_characters.txt")
  end

  test "compress/decompress small.txt" do
    test_file("./sample_text/small.txt")
  end

  test "compress/decompress small2.txt" do
    test_file("./sample_text/small2.txt")
  end

  test "compress/decompress wai-pageauth.txt" do
    test_file("./sample_text/wai-pageauth.txt")
  end

  test "compress/decompress beowulf.txt" do
    test_file("./sample_text/beowulf.txt")
  end

  test "compress/decompress amendments.txt" do
    test_file("./sample_text/amendments.txt")
  end

  test "compress/decompress russian-lorem.txt" do
    test_file("./sample_text/russian-lorem.txt")
  end

  test "compress/decompress english-lorem.txt" do
    test_file("./sample_text/english-lorem.txt")
  end

  test "compress/decompress utf8-demo.txt" do
    test_file("./sample_text/utf8-demo.txt")
  end

  test "compress/decompress empty.txt" do
    test_file("./sample_text/empty.txt")
  end

  test "compress/decompress one_character.txt" do
    test_file("./sample_text/one_character.txt")
  end

  test "compress/decompress one_character_repeated.txt" do
    test_file("./sample_text/one_character_repeated.txt")
  end
end
