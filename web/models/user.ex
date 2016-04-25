defmodule DotsServer.User do
  use DotsServer.Web, :model
  @derive {Poison.Encoder, only: [:id, :email, :handle]}

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :handle, :string
    timestamps

    has_many :game_board_users, DotsServer.GameBoardUser
    has_many :game_boards, through: [:game_board_users, :game_board]
    has_many :next_turn_game_boards, DotsServer.GameBoard, foreign_key: :next_turn_user_id
  end

  @required_fields ~w(email encrypted_password handle)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
