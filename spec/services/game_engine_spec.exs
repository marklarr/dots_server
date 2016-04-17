defmodule DotsServer.GameEngineSpec do
  use ESpec

  alias DotsServer.GameEngine
  alias DotsServer.BoardLines
  alias DotsServer.BoardFills

  import DotsServer.Factory

  let :game_board, do: create(:game_board) |> with_users
  let :player1, do: Enum.at(game_board.users, 0)
  let :player2, do: Enum.at(game_board.users, 1)

  describe "draw_line(game_board, user, from, to)" do
    it "fills in a square for the user if they complete it" do
      game_board = GameEngine.draw_line(game_board, player1, {0, 0}, {0, 1})
      game_board.next_turn_user |> should(eq player2)

      game_board = GameEngine.draw_line(game_board, player2, {0, 1}, {1, 1})
      game_board.next_turn_user |> should(eq player1)

      game_board = GameEngine.draw_line(game_board, player1, {1, 1}, {1, 0})
      game_board.next_turn_user |> should(eq player2)

      game_board = GameEngine.draw_line(game_board, player2, {1, 0}, {0, 0})
      game_board.next_turn_user |> should(eq player2)

      expected_board_lines = [
        [player2.id, nil],
        [player1.id, player1.id, nil],
        [player2.id, nil],
        [nil, nil, nil],
        [nil, nil]
      ]

      expected_board_fills = [
        [player2.id, nil],
        [nil, nil]
      ]

      game_board.board_fills_data
      |> BoardFills.parse
      |> should(eq expected_board_fills)

      game_board.board_lines_data
      |> BoardLines.parse
      |> should(eq expected_board_lines)
    end

    it "lets you play a full game" do
      game_board = game_board
      |> GameEngine.draw_line(player1, {0, 0}, {0, 1})
      |> GameEngine.draw_line(player2, {0, 1}, {1, 1})
      |> GameEngine.draw_line(player1, {1, 1}, {1, 0})
      |> GameEngine.draw_line(player2, {1, 0}, {0, 0})
      |> GameEngine.draw_line(player2, {1, 2}, {2, 2})
      |> GameEngine.draw_line(player1, {2, 0}, {2, 1})
      |> GameEngine.draw_line(player2, {1, 0}, {2, 0})
      |> GameEngine.draw_line(player1, {2, 2}, {2, 1})
      |> GameEngine.draw_line(player2, {1, 1}, {1, 2})
      |> GameEngine.draw_line(player1, {1, 1}, {2, 1})
      |> GameEngine.draw_line(player1, {0, 1}, {0, 2})
      |> GameEngine.draw_line(player2, {0, 2}, {1, 2})

      expected_board_lines = [
        [player2.id, player2.id],
        [player1.id, player1.id, player1.id],
        [player2.id, player1.id],
        [player1.id, player2.id, player1.id],
        [player2.id, player2.id]
      ]

      expected_board_fills = [
        [player2.id, player1.id],
        [player2.id, player1.id]
      ]

      game_board.board_lines_data
      |> BoardLines.parse
      |> should(eq expected_board_lines)

      game_board.board_fills_data
      |> BoardFills.parse
      |> should(eq expected_board_fills)
    end
  end
end
