defmodule DotsServer.GameBoard do
  use DotsServer.Web, :model

  # @board_regex ~r/^[\[\],01]+$/

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
    # |> validate_format(:board_fills_data, @board_regex)
    # |> validate_format(:board_lines_data, @board_regex)
  end
end
