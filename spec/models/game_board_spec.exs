defmodule DotsServer.GameBoardSpec do
  use ESpec

  alias DotsServer.GameBoard

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
end
