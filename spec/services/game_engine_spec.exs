defmodule DotsServer.GameEngineSpec do
  use ESpec

  alias DotsServer.GameEngine
  alias DotsServer.BoardLines
  alias DotsServer.BoardFills

  import DotsServer.Factory

  let :game_board, do: create(:game_board) |> with_users
  let :user1, do: Enum.at(game_board.users, 0)
  let :user2, do: Enum.at(game_board.users, 1)

  describe "new_game(users, size)" do
    let :user1, do: create(:user)
    let :user2, do: create(:user)

    it "makes the first user the next_turn_user" do
      game_board = GameEngine.new_game([user1, user2], 3)
                    |> DotsServer.Repo.preload(:next_turn_user)
      game_board.next_turn_user |> should(eq user1)

      game_board = GameEngine.new_game([user2, user1], 3)
                    |> DotsServer.Repo.preload(:next_turn_user)
      game_board.next_turn_user |> should(eq user2)
    end

    it "attaches both of the users" do
      game_board = GameEngine.new_game([user1, user2], 3)
                    |> DotsServer.Repo.preload(:users)
      game_board.users |> should(eq [user1, user2])
    end

    it "only works if users.count is 2" do
      expect fn() -> GameEngine.new_game([user1], 3) end
      |> to(raise_exception)

      user3 = create(:user)
      expect fn() -> GameEngine.new_game([user1], 3) end
      |> to(raise_exception)
    end

    it "makes the appropriate board_lines" do
      game_board = GameEngine.new_game([user1, user2], 3)
      expected = [
        [:nil, :nil],
        [:nil, :nil, :nil],
        [:nil, :nil],
        [:nil, :nil, :nil],
        [:nil, :nil],
      ]

      game_board.board_lines_data
      |> BoardLines.parse
      |> should(eq expected)
    end

    it "makes the appropriate board_fills" do
      game_board = GameEngine.new_game([user1, user2], 3)
      expected = [
        [:nil, :nil],
        [:nil, :nil],
      ]

      game_board.board_fills_data
      |> BoardFills.parse
      |> should(eq expected)
    end
  end

  describe "draw_line(game_board, user, from, to)" do
    it "fills in a square for the user if they complete it" do
      {:ok, game_board} = GameEngine.draw_line(game_board, user1, {0, 0}, {0, 1})
      game_board.next_turn_user |> should(eq user2)

      {:ok, game_board} = GameEngine.draw_line(game_board, user2, {0, 1}, {1, 1})
      game_board.next_turn_user |> should(eq user1)

      {:ok, game_board} = GameEngine.draw_line(game_board, user1, {1, 1}, {1, 0})
      game_board.next_turn_user |> should(eq user2)

      {:ok, game_board} = GameEngine.draw_line(game_board, user2, {1, 0}, {0, 0})
      game_board.next_turn_user |> should(eq user2)

      expected_board_lines = [
        [user2.id, nil],
        [user1.id, user1.id, nil],
        [user2.id, nil],
        [nil, nil, nil],
        [nil, nil]
      ]

      expected_board_fills = [
        [user2.id, nil],
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
      {:ok, game_board} = game_board |> GameEngine.draw_line(user1, {0, 0}, {0, 1})
      {:error, msg} = game_board |> GameEngine.draw_line(user1, {0, 1}, {1, 1})
      msg |> should(eq "player #{user1.id} cannot go on player #{user2.id}'s turn")
      {:error, msg} = game_board |> GameEngine.draw_line(user2, {0, 0}, {0, 1})
      msg |> should(eq "line already drawn from {0, 0} to {0, 1}")
      {:ok, game_board} = game_board |> GameEngine.draw_line(user2, {0, 1}, {1, 1})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user1, {1, 1}, {1, 0})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user2, {1, 0}, {0, 0})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user2, {1, 2}, {2, 2})
      {:error, msg} = game_board |> GameEngine.draw_line(user1, {1, 1}, {1, 1})
      msg |> should(eq "line is to itself from {1, 1} to {1, 1}")
      {:ok, game_board} = game_board |> GameEngine.draw_line(user1, {2, 0}, {2, 1})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user2, {1, 0}, {2, 0})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user1, {2, 2}, {2, 1})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user2, {1, 1}, {1, 2})
      {:error, msg} = game_board |> GameEngine.draw_line(user1, {1, 1}, {2, 2})
      msg |> should(eq "cannot draw line in unknown direction from {1, 1} to {2, 2}")
      {:ok, game_board} = game_board |> GameEngine.draw_line(user1, {1, 1}, {2, 1})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user1, {0, 1}, {0, 2})
      {:ok, game_board} = game_board |> GameEngine.draw_line(user2, {0, 2}, {1, 2})
      {:error, msg} = game_board |> GameEngine.draw_line(user2, {0, 2}, {1, 2})
      msg |> should(eq "game is over")

      expected_board_lines = [
        [user2.id, user2.id],
        [user1.id, user1.id, user1.id],
        [user2.id, user1.id],
        [user1.id, user2.id, user1.id],
        [user2.id, user2.id]
      ]

      expected_board_fills = [
        [user2.id, user1.id],
        [user2.id, user1.id]
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
