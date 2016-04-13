defmodule DotsServer.BoardLines do
  require Integer
  alias DotsServer.SinglyNestedList

  @filled_line :filled_line
  @unfilled_line :unfilled_line
  @horizontal :horizontal
  @vertical :vertical

  def new(size) do
    Enum.map 1..((size * 2) -1 ), fn(row) ->
      range = if Integer.is_odd(row), do: 1..(size-1), else: 1..size
      Enum.map range, fn(_) -> @unfilled_line end
    end
  end

  def parse(board_lines_data) do
    board_lines_data
    |> SinglyNestedList.parse
    |> SinglyNestedList.deep_map(fn(x) -> String.to_atom(x) end)
  end

  def data(board_fills), do: Poison.encode!(board_fills)

  def fill_line(board_lines, from, to) do
    point = case line_direction(from, to) do
      :horizontal ->
        {line_tail_x(from, to), (line_tail_y(from, to) + 1) * 2 - 1}
      :vertical ->
        {line_tail_x(from, to), (line_tail_y(from, to) + 1) * 2}
    end

    SinglyNestedList.replace_at(board_lines, point, @filled_line)
  end

  defp line_tail_x({_from_x, from_y}, {_to_x, to_y}), do: Enum.min [from_y, to_y]
  defp line_tail_y({from_x, _from_y}, {to_x, _to_y}), do: Enum.min [from_x, to_x]

  defp line_direction({from_x, from_y}, {to_x, to_y}) do
    cond do
      from_x == to_x -> :horizontal
      from_y == to_y -> :vertical
    end
  end
end
