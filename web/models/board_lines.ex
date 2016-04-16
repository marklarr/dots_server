defmodule DotsServer.BoardLines do
  require Integer
  alias DotsServer.SinglyNestedList

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
    with {:ok, point} <- line_point(from, to),
         :ok <- assert_is_valid_line(from, to),
         :ok <- assert_is_available_point(board_lines, point, from, to),
    do: {:ok, SinglyNestedList.replace_at(board_lines, point, user.id)}
  end

  def line_filled?(board_lines, from, to) do
    case line_point(from, to) do
      {:ok, point} -> !Enum.member?([nil, :out_of_bounds], SinglyNestedList.at(board_lines, point))
      {:error, _msg} -> false
    end
  end

  def line_direction({from_x, from_y}, {to_x, to_y}) do
    cond do
      from_y == to_y -> :horizontal
      from_x == to_x -> :vertical
      true -> :unknown
    end
  end

  defp line_point(from, to) do
    case line_direction(from, to) do
      :horizontal ->
        {:ok, {line_tail_x(from, to), line_tail_y(from, to) * 2}}
      :vertical ->
        {:ok, {line_tail_x(from, to), line_tail_y(from, to) * 2 + 1}}
      :unknown ->
        make_error("cannot draw line in unknown direction", from, to)
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
        make_error("line is to itself", from, to)
      (differential_x == -1 && differential_y == -1) || (differential_x == 1 && differential_y == 1) ->
        make_error("line is diagonal", from, to)
      true ->
        make_error("line is more than one unit long", from, to)
    end
  end

  defp make_error(message, from, to) do
    {:error, message <> " from #{inspect(from)} to #{inspect(to)}"}
  end

  defp assert_is_available_point(board_lines, point, from, to) do
    case SinglyNestedList.at(board_lines, point) do
      nil ->
        :ok
      :out_of_bounds ->
        make_error("line does not exist", from, to)
      _user_id ->
        make_error("line already drawn", from , to)
    end
  end

  defp line_tail_y({_from_x, from_y}, {_to_x, to_y}), do: Enum.min [from_y, to_y]
  defp line_tail_x({from_x, _from_y}, {to_x, _to_y}), do: Enum.min [from_x, to_x]
end
