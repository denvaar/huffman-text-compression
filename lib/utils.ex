defmodule Utils do
  @moduledoc """
  Collection of helper functions for
  text compression using Huffman coding
  algorithm.
  """

  defp codepoint(character) do
    <<code::utf8>> = character
    code
  end

  @doc """
  Convert character(s) to binary representation.

  ## Examples

      iex> Utils.to_binary("dog")
      "011001000110111101100111"

      iex> Utils.to_binary("a")
      "01100001"

  """
  def to_binary(data) do
    data
    |> String.graphemes
    |> Enum.map(fn(character) ->
      character
      |> codepoint
      |> Integer.to_string(2)
      |> String.pad_leading(8, "0") end)
    |> Enum.join
  end
end
