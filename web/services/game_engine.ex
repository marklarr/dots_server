defmodule DotsServer.GameEngine do

  alias DotsServer.GameBoard
  alias DotsServer.BoardLines
  alias DotsServer.BoardFills

  def draw_line(game_board, user, from, to) do
    with {:ok, board_lines} <- game_board.board_lines_data |> BoardLines.parse |> BoardLines.fill_line(user, from, to),
    {:ok, origins_to_fill}  <- determine_board_fill_origins(board_lines, from, to),
    {:ok, board_fills}      <- game_board.board_fills_data |> BoardFills.parse |> make_fills(origins_to_fill, user),
    {:ok, next_turn_user}   <- determine_next_turn_user(game_board, user, origins_to_fill),
    do: do_game_board_update(game_board, next_turn_user, board_lines, board_fills)
  end

  defp determine_next_turn_user(game_board, user, origins_to_fill) do
    if Enum.any?(origins_to_fill) do
      {:ok, user}
    else
      game_board = game_board |> DotsServer.Repo.preload(:users)
      {:ok, Enum.at(game_board.users -- [user], 0)}
    end
  end

  defp make_fills(board_fills, origins_to_fill, user) do
    Enum.reduce(origins_to_fill, {:ok, board_fills}, fn(origin_to_fill, ok_board_fills) ->
      with {:ok, board_fills} <- ok_board_fills,
      do: BoardFills.fill_block(board_fills, user, origin_to_fill)
    end)
  end

  defp do_game_board_update(game_board, next_turn_user, board_lines, board_fills) do
    game_board = DotsServer.Repo.preload(game_board, :users)

    game_board
    |> GameBoard.changeset(%{
            board_lines_data: BoardLines.data(board_lines),
            board_fills_data: BoardFills.data(board_fills),
            next_turn_user_id: next_turn_user.id
       })
    |> DotsServer.Repo.update!

    DotsServer.Repo.get(GameBoard, game_board.id) |> DotsServer.Repo.preload(:next_turn_user)
  end

  defp lines_making_square_for_horizontal(from, to) do
    {from_x, _from_y} = from
    {to_x, to_y} = to
    line_1 = [from: from, to: to]
    line_2a = [from: line_1[:to], to: {to_x, to_y - 1}]
    line_2b = [from: line_1[:to], to: {to_x, to_y + 1}]
    line_3a = [from: line_1[:from], to: {from_x, to_y - 1}]
    line_3b = [from: line_1[:from], to: {from_x, to_y + 1}]
    line_4a = [from: line_2a[:to], to: line_3a[:to]]
    line_4b = [from: line_2b[:to], to: line_3b[:to]]
    [
      [line_1, line_2a, line_3a, line_4a],
      [line_1, line_2b, line_3b, line_4b]
    ]
  end

  defp lines_making_square_for_vertical(from, to) do
    {from_x, _from_y} = from
    {to_x, to_y} = to
    line_1 = [from: from, to: to]
    line_2a = [from: line_1[:to], to: {to_x - 1, to_y}]
    line_2b = [from: line_1[:to], to: {to_x + 1, to_y}]
    line_3a = [from: line_1[:from], to: {from_x - 1, to_y}]
    line_3b = [from: line_1[:from], to: {from_x + 1, to_y}]
    line_4a = [from: line_2a[:to], to: line_3a[:to]]
    line_4b = [from: line_2b[:to], to: line_3b[:to]]
    [
      [line_1, line_2a, line_3a, line_4a],
      [line_1, line_2b, line_3b, line_4b]
    ]
  end

  defp points(lines) do
    lines
    |> Enum.reduce([], fn(line, acc) -> [line[:from]| [line[:to]|acc] ] end)
    |> Enum.uniq
  end

  defp determine_origin(lines_making_square) do
    lines_making_square
    |> points
    |> Enum.min_by(fn({x, y}) -> x + y end)
  end

  defp all_lines_filled?(board_lines, lines) do
    Enum.all? lines, fn(line) -> BoardLines.line_filled?(board_lines, line[:from], line[:to]) end
  end

  defp determine_board_fill_origins(board_lines, from, to) do
    lines_making_square_enum = case BoardLines.line_direction(from, to) do
      :horizontal -> lines_making_square_for_horizontal(from, to)
      :vertical -> lines_making_square_for_vertical(from, to)
    end

    filled_lines_making_square_enum = Enum.filter lines_making_square_enum, fn(lines_making_square) ->
      all_lines_filled?(board_lines, lines_making_square)
    end

    board_fill_origins = Enum.map filled_lines_making_square_enum, fn(filled_lines_making_square) ->
      determine_origin(filled_lines_making_square)
    end

    {:ok, board_fill_origins}
  end
end
