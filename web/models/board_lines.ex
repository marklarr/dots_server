defmodule DotsServer.BoardLines do
  require Integer
  alias DotsServer.SinglyNestedList

  @horizontal :horizontal
  @vertical :vertical

  def new(board_size) do
    Enum.map 1..((board_size * 2) -1 ), fn(row) ->
      range = if Integer.is_odd(row), do: 1..(board_size-1), else: 1..board_size
      Enum.map range, fn(_) -> nil end
    end
  end

  def parse(board_lines_data) do
    board_lines_data
    |> SinglyNestedList.parse
  end

  def data(board_fills), do: Poison.encode!(board_fills)

  def fill_line(board_lines, user, from, to) do
    case assert_is_valid_line(from, to) do
      {:error, msg} ->
        {:error, msg <> " from #{inspect(from)} to #{inspect(to)}"}
      :ok ->
        point = line_point(from, to)
        case assert_is_available_point(board_lines, point) do
          {:error, msg} ->
            {:error, msg <> " from #{inspect(from)} to #{inspect(to)}"}
          :ok ->
            SinglyNestedList.replace_at(board_lines, point, user.id)
        end
    end
  end

  defp line_point(from, to) do
    case line_direction(from, to) do
      @horizontal ->
        {line_tail_x(from, to), (line_tail_y(from, to) + 1) * 2 - 1}
      @vertical ->
        {line_tail_x(from, to), (line_tail_y(from, to) + 1) * 2}
    end
  end

  defp assert_is_valid_line(from, to) do
    {from_x, from_y} = from
    {to_x, to_y} = to
    {differential_x, differential_y} = {from_x - to_x, from_y - to_y}

    cond do
      (abs(differential_x) == 1 && differential_y == 0) || (abs(differential_y) == 1 && differential_x == 0) ->
        :ok
      differential_x == 0 && differential_y == 0 ->
        {:error, "line is to itself"}
      (differential_x == -1 && differential_y == -1) || (differential_x == 1 && differential_y == 1) ->
        {:error, "line is diagonal"}
      true ->
        {:error, "line is more than one unit long"}
    end
  end

  defp assert_is_available_point(board_lines, point) do
    case SinglyNestedList.at(board_lines, point) do
      nil ->
        :ok
      :out_of_bounds ->
        {:error, "line does not exist"}
      _user_id ->
        {:error, "line already drawn"}
    end
  end

  defp do_fill_line(board_lines, from, to) do
  end

  defp line_tail_x({_from_x, from_y}, {_to_x, to_y}), do: Enum.min [from_y, to_y]
  defp line_tail_y({from_x, _from_y}, {to_x, _to_y}), do: Enum.min [from_x, to_x]

  defp line_direction({from_x, from_y}, {to_x, to_y}) do
    cond do
      from_x == to_x -> @horizontal
      from_y == to_y -> @vertical
    end
  end
end
