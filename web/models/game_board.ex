defmodule DotsServer.GameBoard do
  use DotsServer.Web, :model

  @board_regex ~r/^[\[\],01]+$/

  schema "game_boards" do
    field :board_lines, :binary
    field :board_fills, :binary

    timestamps
  end

  @required_fields ~w(board_lines board_fills)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_format(:board_fills, @board_regex)
    |> validate_format(:board_lines, @board_regex)
  end
end
