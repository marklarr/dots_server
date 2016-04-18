defmodule DotsServer.GameBoard do
  use DotsServer.Web, :model

  alias DotsServer.BoardLines
  alias DotsServer.BoardFills

  schema "game_boards" do
    field :board_lines_data, :binary
    field :board_fills_data, :binary
    timestamps

    has_many :game_board_users, DotsServer.GameBoardUser
    has_many :users, through: [:game_board_users, :user]
    belongs_to :next_turn_user, DotsServer.User
  end

  @required_fields ~w(board_lines_data board_fills_data)
  @optional_fields ~w(next_turn_user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def winner_user(game_board) do
    if game_over?(game_board) do
      fills_by_user = game_board.board_fills_data
      |> BoardFills.parse
      |> List.flatten
      |> Enum.group_by(fn(user_id) -> user_id end)

      game_board = DotsServer.Repo.preload(game_board, :users)
      user1 = Enum.at(game_board.users, 0)
      user2 = Enum.at(game_board.users, 1)
      user1_score = fills_by_user
                    |> Map.get(user1.id)
                    |> Enum.count
      user2_score = fills_by_user
                    |> Map.get(user2.id)
                    |> Enum.count
      cond do
        user1_score > user2_score -> user1
        user2_score > user1_score -> user2
        user1_score == user2_score -> nil
      end
    else
      nil
    end
  end

  def game_over?(game_board) do
    !(game_board.board_lines_data
    |> BoardLines.parse
    |> List.flatten
    |> Enum.member?(nil))
  end
end
