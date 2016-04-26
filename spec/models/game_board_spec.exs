defmodule DotsServer.GameBoardSpec do
  use ESpec

  alias DotsServer.GameBoard
  alias DotsServer.BoardLines
  alias DotsServer.BoardFills
  alias DotsServer.GameBoardUser
  alias DotsServer.GameEngine

  import DotsServer.Factory

  let :user1, do: create(:user)
  let :user2, do: create(:user)

  defp attach_user(game_board, user) do
    DotsServer.Repo.insert!(%GameBoardUser{game_board_id: game_board.id, user_id: user.id})
    game_board
  end

  let :tied_game_over_game_board do
      board_lines = [
        [user2.id, user2.id],
        [user1.id, user1.id, user1.id],
        [user2.id, user1.id],
        [user1.id, user2.id, user1.id],
        [user2.id, user2.id]
      ]

      board_fills = [
        [user2.id, user1.id],
        [user2.id, user1.id]
      ]

      create(:game_board, %{board_lines_data: BoardLines.data(board_lines), board_fills_data: BoardFills.data(board_fills)})
      |> attach_user(user1)
      |> attach_user(user2)
  end

  let :user2_wins_game_over_game_board do
      board_lines = [
        [user2.id, user2.id],
        [user1.id, user1.id, user1.id],
        [user2.id, user1.id],
        [user1.id, user2.id, user1.id],
        [user2.id, user2.id]
      ]

      board_fills = [
        [user2.id, user1.id],
        [user2.id, user2.id]
      ]

      create(:game_board, %{board_lines_data: BoardLines.data(board_lines), board_fills_data: BoardFills.data(board_fills)})
      |> attach_user(user1)
      |> attach_user(user2)
  end

  let :new_game_board do
    create(:game_board)
    |> attach_user(user1)
    |> attach_user(user2)
  end

  describe "#changeset" do
    context "valid attributes" do
      let :valid_attrs, do: %{board_fills_data: Poison.encode!([[0, 1], [0, 1]]), board_lines_data: Poison.encode!([[1, 1], [1, 1]])}

      it "makes a valid changeset" do
        changeset = GameBoard.changeset(%GameBoard{}, valid_attrs)
        changeset.valid? |> should(be_true)
      end
    end

    context "changeset with invalid attributes" do
      let :invalid_attrs, do: %{}

      it "makes an invalid changeset" do
        changeset = GameBoard.changeset(%GameBoard{}, invalid_attrs)
        changeset.valid? |> should(be_false)
      end
    end
  end

  describe "game_over?(game_board)" do
    it "is true if all board_lines are filled" do
      tied_game_over_game_board
      |> GameBoard.game_over?
      |> should(eq true)

      user2_wins_game_over_game_board
      |> GameBoard.game_over?
      |> should(eq true)
    end

    it "is false if there are remaining board_lines" do
      new_game_board
      |> GameBoard.game_over?
      |> should(eq false)
    end
  end

  describe "winner_user(game_board)" do
    context "game is not over yet" do
      it "there is no winner yet" do
        new_game_board
        |> GameBoard.winner_user
        |> should(eq nil)
      end
    end

    context "game is over" do
      it "is the user with more board_fills" do
        user2_wins_game_over_game_board
        |> GameBoard.winner_user
        |> should(eq user2)
      end

      it "is nil if users are tied for board_fills" do
        tied_game_over_game_board
        |> GameBoard.winner_user
        |> should(eq nil)
      end
    end
  end

  describe "encoding with Poison" do
    it "encodes the id, users, board_fills, board_lines, winner_user, game_over, and next_turn_user" do
      game_board = GameEngine.new_game([user1, user2], 3)
      Poison.decode!(Poison.encode!(game_board)) |> should(eq %{
        "id" => game_board.id,
        "board_lines" => [
          [nil, nil],
          [nil, nil, nil],
          [nil, nil],
          [nil, nil, nil],
          [nil, nil]
        ],
        "board_fills" => [
          [nil, nil],
          [nil, nil]
        ],
        "users" => [
          %{
            "id" => user1.id,
            "handle" => user1.handle,
            "email" => user1.email
          },
          %{
            "id" => user2.id,
            "handle" => user2.handle,
            "email" => user2.email
          }
        ],
        "next_turn_user" => %{
          "id" => user1.id,
          "handle" => user1.handle,
          "email" => user1.email
        },
        "game_over" => false,
        "winner_user" => nil
      })
    end
  end
end
