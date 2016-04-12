defmodule DotsServer.BoardLinesTest do
  use ESpec
  alias DotsServer.BoardLines

  describe "new(size)" do
    it "returns a new board_lines for a size x size board" do
      expected = [
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line, :unfilled_line]
        ]
      BoardLines.new(5) |> should(eq expected)
    end
  end

  describe "parse(board_lines_data)" do
    it "returns a board_lines" do
      BoardLines.new(3)
      |> Poison.encode!
      |> BoardLines.parse
      |> should(eq BoardLines.new(3))
    end
  end

  describe "data(board_lines)" do
    it "returns a bitstring" do
      board_lines_data = BoardLines.new(3) |> BoardLines.data

      is_bitstring(board_lines_data) |> should(be_true)
    end

    it "returns a board_lines_data" do
      BoardLines.new(3)
      |> BoardLines.data
      |> BoardLines.parse
      |> should(eq BoardLines.new(3))
    end
  end

  describe "fill_line(from, to)" do
    it "fills a line on the board from point to point" do
      # 2, 3
      expected = [
        [:unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line],
        [:unfilled_line, :filled_line, :unfilled_line],
        [:unfilled_line, :unfilled_line],
      ]
      BoardLines.new(3)
      |> BoardLines.fill_line({1, 1}, {1, 2})
      |> should(eq expected)
    end
    it "does not fill the line if it has already been filled"
    it "does not fill the line if it does not exist"
    it "does not fill the line if it's more than 1 unit long"
    it "does not fill the line if it's itself"
  end

end
