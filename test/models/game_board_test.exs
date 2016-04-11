defmodule DotsServer.GameBoardTest do
  use ESpec

  alias DotsServer.GameBoard

  describe "#changeset" do

    context "valid attributes" do
      let :valid_attrs, do: %{board_fills: Poison.encode!([[0, 1], [0, 1]]), board_lines: Poison.encode!([[1, 1], [1, 1]])}

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

    context "board_fills contains something other than 1's and 0's" do
      let :invalid_attrs, do: %{board_fills: Poison.encode!([[1, 2], [1, 2]]), board_lines: Poison.encode!([[0, 1], [0, 1]])}


      it "makes an invalid changeset" do
        changeset = GameBoard.changeset(%GameBoard{}, invalid_attrs)
        changeset.valid? |> should(be_false)
      end
    end

    context "board_lines contains something other than 1's and 0's" do
      let :invalid_attrs, do: %{board_fills: Poison.encode!([[1, 0], [1, 0]]), board_lines: Poison.encode!([[2, 1], [2, 1]])}

      it "makes an invalid changeset" do
        changeset = GameBoard.changeset(%GameBoard{}, invalid_attrs)
        changeset.valid? |> should(be_false)
      end
    end
  end
end
