defmodule DotsServer.BoardFills do
  @filled :filled
  @empty :empty

  def parse(board_fills_data) do
    board_fills_data
    |> Poison.decode!
    |> deep_map(fn(x) -> String.to_atom(x) end)
  end

  def data(board_fills), do: Poison.encode!(board_fills)

  def fill_block(board_fills, {origin_x, origin_y}) do
    case board_fills |> at({origin_x, origin_y}) do
      nil ->
        {:error, "board_fills does not contain origin_point (#{origin_x}, #{origin_y})"}
      @filled ->
        {:error, "board_fills is already filled at origin_point (#{origin_x}, #{origin_y})"}
      @empty ->
        new_row = board_fills |> Enum.at(origin_x) |> List.replace_at(origin_y, @filled)
        board_fills |> List.replace_at(origin_x, new_row)
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
