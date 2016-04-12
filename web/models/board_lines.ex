defmodule DotsServer.BoardLines do
  require Integer

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
    |> Poison.decode!
    |> deep_map(fn(x) -> String.to_atom(x) end)
  end

  def data(board_fills), do: Poison.encode!(board_fills)

  def fill_line(board_lines, from, to) do
    {x, y} = case line_direction(from, to) do
      :horizontal ->
        {line_tail_x(from, to), (line_tail_y(from, to) + 1) * 2 - 1}
      :vertical ->
        {line_tail_x(from, to), (line_tail_y(from, to) + 1) * 2}
    end

    row = board_lines
    |> Enum.at(y)
    |> List.replace_at(x, @filled_line)

    List.replace_at(board_lines, y, row)
  end

  defp line_tail_x({_from_x, from_y}, {_to_x, to_y}), do: Enum.min [from_y, to_y]
  defp line_tail_y({from_x, _from_y}, {to_x, _to_y}), do: Enum.min [from_x, to_x]

  defp line_direction({from_x, from_y}, {to_x, to_y}) do
    cond do
      from_x == to_x -> :horizontal
      from_y == to_y -> :vertical
    end
  end


  defp at(board_fills, {x, y}) do
    case Enum.at(board_fills, x) do
      nil -> nil
      row -> Enum.at(row, y)
    end
  end


  defp deep_map(list, fun) when is_list(list) do
    Enum.map(list, fn(x) -> deep_map(x, fun) end)
  end

  defp deep_map(not_list, fun) do
    fun.(not_list)
  end
end
