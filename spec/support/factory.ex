defmodule DotsServer.Factory do
  use ExMachina.Ecto, repo: DotsServer.Repo

  alias DotsServer.User
  alias DotsServer.GameBoard
  alias DotsServer.GameBoardUser
  alias DotsServer.BoardLines
  alias DotsServer.BoardFills

  def factory(:user) do
    %User{
      handle: sequence(:handle, &"d0t1n4t0r-#{&1}"),
      email: sequence(:email, &"email-#{&1}@fake.com"),
      encrypted_password: :crypto.hash(:sha256, "my_pass123") |> Base.encode16
    }
  end

  def factory(:game_board) do
    %GameBoard{
      board_lines_data: BoardLines.new(3) |> BoardLines.data,
      board_fills_data: BoardFills.new(3) |> BoardFills.data
    }
  end

  def factory(:game_board_user) do
    %GameBoardUser{
      user: build(:user),
      game_board: build(:game_board)
    }
  end

  def with_users(game_board) do
    p1 = create(:game_board_user, %{game_board: game_board}).user
    create(:game_board_user, %{game_board: game_board})
    game_board |> GameBoard.changeset(%{next_turn_user_id: p1.id}) |> DotsServer.Repo.update!
    DotsServer.Repo.get!(GameBoard, game_board.id) |> DotsServer.Repo.preload(:users)
  end
end
