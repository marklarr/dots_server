defmodule DotsServer.GameBoardTest do
  use DotsServer.ModelCase

  alias DotsServer.GameBoard

  @valid_attrs %{board_fills: "some content", board_lines: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GameBoard.changeset(%GameBoard{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GameBoard.changeset(%GameBoard{}, @invalid_attrs)
    refute changeset.valid?
  end
end
