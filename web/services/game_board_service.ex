defmodule DotsServer.GameBoardService do
  alias DotsServer.GameBoard

  def create_board(size) do
    attrs = %{board_lines_data: encode(init_board_lines(size)), board_fills_data: encode(init_board_fills(size))}
    changeset = GameBoard.changeset(%GameBoard{}, attrs)
    DotsServer.Repo.insert!(changeset)
  end

  def board_lines(game_board) do
    decode(game_board.board_lines_data)
  end

  def board_fills(game_board) do
    decode(game_board.board_fills_data)
  end

  defp decode(board_array) do
    Poison.decode!(board_array)
  end

  defp encode(board_array) do
    Poison.encode!(board_array)
  end

  defp init_board_lines(size) do
    Enum.map 1..size, fn _x ->
      Enum.map 1..size, fn _x -> 0 end
    end
  end

  defp init_board_fills(size) do
    init_board_lines(size - 1)
  end
end
