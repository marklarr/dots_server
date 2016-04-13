defmodule DotsServer.BoardFills do
  alias DotsServer.SinglyNestedList

  @filled :filled
  @empty :empty

  def new(board_size) do
    Enum.map 1..(board_size - 1), fn(_row) ->
      Enum.map 1..(board_size - 1), fn(_column) ->
        :empty
      end
    end
  end

  def parse(board_fills_data) do
    board_fills_data
    |> SinglyNestedList.parse
    |> SinglyNestedList.deep_map(fn(x) -> String.to_atom(x) end)
  end

  def data(board_fills), do: SinglyNestedList.data(board_fills)

  def fill_block(board_fills, origin) do
    case board_fills |> SinglyNestedList.at(origin) do
      :out_of_bounds ->
        {:error, "board_fills does not contain origin_point #{inspect(origin)}"}
      @filled ->
        {:error, "board_fills is already filled at origin_point #{inspect(origin)}"}
      @empty ->
        SinglyNestedList.replace_at(board_fills, origin, @filled)
    end
  end
end
