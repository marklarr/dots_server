defmodule DotsServer.BoardFills do
  alias DotsServer.SinglyNestedList

  def new(board_size) do
    Enum.map 1..(board_size - 1), fn(_row) ->
      Enum.map 1..(board_size - 1), fn(_column) ->
        nil
      end
    end
  end

  def parse(board_fills_data) do
    board_fills_data
    |> SinglyNestedList.parse
  end

  def data(board_fills), do: SinglyNestedList.data(board_fills)

  def fill_block(board_fills, user, origin) do
    case board_fills |> SinglyNestedList.at(origin) do
      nil ->
        {:ok, SinglyNestedList.replace_at(board_fills, origin, user.id)}
      :out_of_bounds ->
        {:error, "board_fills does not contain origin_point #{inspect(origin)}"}
      _user_id ->
        {:error, "board_fills is already filled at origin_point #{inspect(origin)}"}
    end
  end
end
