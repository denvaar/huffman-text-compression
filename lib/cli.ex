defmodule Huffman.CLI do
  def main(args \\ []) do
    args
    |> parse_arguments
    |> perform_action
  end

  defp parse_arguments(args) do
    {opts, _args, _invalid} =
      args
      |> OptionParser.parse(switches: [compress: :string, decompress: :string, output_path: :string])

    opts
  end

  defp perform_action([compress: file_path]), do: Huffman.FileTools.compress(file_path)

  defp perform_action([compress: file_path, output_path: out_file]) do
    Huffman.FileTools.compress(file_path, out_file)
  end

  defp perform_action([decompress: file_path]), do: Huffman.FileTools.decompress(file_path)

  defp perform_action([decompress: file_path, output_path: out_file]) do
    Huffman.FileTools.decompress(file_path, out_file)
  end

  defp perform_action(_) do
    message =
      """
      Command line tool for Huffman Coding Text compression

      OPTIONS
      =================================
      --compress path/to/text_file.txt --output-path path/to/output_file.huff

      --decompress path/to/compressed_file.huff --output-path path/to/output_file.txt

      """
    IO.puts(message)
  end
end
