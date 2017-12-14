defmodule MinHeap do
  defp bubble_up(heap, item_index) do
    parent_index = div(item_index, 2)
    if parent_index > 0 do
      item = Enum.at(heap, item_index)
      parent = Enum.at(heap, parent_index)
      if item.freq > parent.freq do
        heap
        |> List.replace_at(item_index, parent)
        |> List.replace_at(parent_index, item)
        |> bubble_up(parent_index)
      else
        heap
      end
    else
      heap
    end
  end

  def insert(item), do: [%{freq: 0, character: nil}, item]
  def insert([], item), do: [%{freq: 0, character: nil}, item]
  def insert(nil, item), do: [%{freq: 0, character: nil}, item]
  def insert(heap, item) do
    new_heap = heap ++ [item]
    bubble_up(new_heap, length(new_heap) - 1)
  end
end
