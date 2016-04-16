defmodule DotsServer.GameBoardUser do
  use DotsServer.Web, :model

  schema "game_board_users" do
    belongs_to :user, DotsServer.User
    belongs_to :game_board, DotsServer.GameBoard

    timestamps
  end

  @required_fields ~w()
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
