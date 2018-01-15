# Huffman

Implementation of Huffman Coding algorithm for lossless text compression.

I wrote some stuff about this project [here](https://denverpsmith.com/articles/exploring-text-compression).

Here are a few results:

| Text File         | Original Size | Compressed Size   | % Smaller    |
| ----------------- | ------------- | ----------------- | ------------ |
| big.txt           | 6.2M          | 3.5M              | 44%          |
| beowulf.txt       | 294K          | 163K              | 45%          |
| wai-pageauth.txt  | 82K           | 47K               | 43%          |
| amendments.txt    | 44K           | 25K               | 43%          |
| utf8-demo.txt     | 14K           | 8.5K              | 39%          |
| russian-lorem.txt | 4.5K          | 1.4K              | 68%          |
| english-lorem.txt | 1.2K          | 738B              | 39%          |
| small.txt         | 28B           | 38B               | 36% increase |

It works best on large text files. Small text files actually get larger after compression using this technique because there is overhead.

# Usage

### Interactive Elixir console
```elixir
iex(1)> {encoded_bits, mapping} = Huffman.compress("hello world")
{"h'iO",
 %{2 => %{<<0::size(2)>> => "l"},
   3 => %{<<2::size(3)>> => "e", <<3::size(3)>> => "h", <<4::size(3)>> => "o",
     <<5::size(3)>> => "r", <<6::size(3)>> => "w"},
   4 => %{<<14::size(4)>> => " ", <<15::size(4)>> => "d"}}}

iex(2)> Huffman.decompress(encoded_bits, mapping)
"hello world"
```

### Read/Write to file from interactive Elixir console
```elixir
iex(1)> Huffman.Files.compress("./sample_text/amendments.txt", "./out.txt.huff")
"Data written to -> ./out.txt"

iex(2)> Huffman.Files.decompress("./out.txt.huff", "./out.txt")
"File decompression complete ./out.txt"
```

### Command line usage

First, build the executable:

```bash
$ mix escript.build
Generated escript huffman with MIX_ENV=dev
```

```bash
$ ./huffman
Command line tool for Huffman Coding Text compression

OPTIONS
=================================
--compress path/to/text_file.txt --output-path path/to/output_file.huff

--decompress path/to/compressed_file.huff --output-path path/to/output_file.txt
```

# Contributing

This code could of course be improved, so feel free to contribute.
