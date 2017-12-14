defmodule UtilsTest do
  use ExUnit.Case
  doctest Utils

  test "convert text or character to 8-bit binary representation" do
    assert Utils.to_binary("a") == "01100001"
    assert Utils.to_binary("apple") == "0110000101110000011100000110110001100101"
  end
end
