defmodule DotsServer.GameBoardServiceSpec do
  use ESpec
  alias DotsServer.GameBoardService
  alias DotsServer.GameBoard

  context "a simple board" do
    let :valid_attrs, do: %{board_fills_data: Poison.encode!([[0, 1], [0, 1]]), board_lines_data: Poison.encode!([[1, 1], [1, 0]])}
    let :change_set, do: GameBoard.changeset(%GameBoard{}, valid_attrs)
    let :game_board, do: DotsServer.Repo.insert!(change_set)

    describe "board_fills(game_board)" do
      it "returns game_board.board_fills as an enum" do
        game_board |> GameBoardService.board_fills |> should(eq [[0, 1], [0, 1]])
      end
    end

    describe "board_lines(game_board)" do
      it "returns game_board.board_lines as an enum" do
        game_board |> GameBoardService.board_lines |> should(eq [[1, 1], [1, 0]])
      end
    end
  end

  describe "create_board(size)" do
    let :game_board, do: GameBoardService.create_board(7)

    it "creates a size by size board_lines with all 0's" do
      expected = [ [0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0, 0] ]

      game_board |> GameBoardService.board_lines |> should(eq expected)
    end

    it "creates a size - 1 by size - 1 board_fills with all 0's" do
      expected = [
                    [0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0],
                    [0, 0, 0, 0, 0, 0],
                  ]

      game_board |> GameBoardService.board_fills |> should(eq expected)
    end
  end
end
