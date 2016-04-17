defmodule DotsServer.BoardLinesSpec do
  use ESpec

  alias DotsServer.BoardLines

  import DotsServer.Factory

  let :user, do: create(:user)

  describe "new(board_size)" do
    it "returns a new board_lines for a size x size board" do
      expected = [
        [:nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil, :nil],
        [:nil, :nil, :nil, :nil]
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

  describe "fill_line(user, from, to)" do
    it "fills a line on the board for the user from point to point" do
      expected = [
        [:nil, :nil],
        [:nil, :nil, :nil],
        [:nil, :nil],
        [:nil, user.id, :nil],
        [:nil, :nil],
      ]
      BoardLines.new(3)
      |> BoardLines.fill_line(user, {1, 1}, {1, 2})
      |> should(eq {:ok, expected})
    end

    it "does not fill the line if it has already been filled" do
      {:ok, board_lines} = BoardLines.new(3)
      |> BoardLines.fill_line(user, {1, 1}, {1, 2})

      board_lines
      |> BoardLines.fill_line(user, {1, 1}, {1, 2})
      |> should(eq {:error, "line already drawn from {1, 1} to {1, 2}"})

      {:ok, board_lines} = BoardLines.new(3)
      |> BoardLines.fill_line(user, {1, 1}, {1, 2})

      board_lines
      |> BoardLines.fill_line(user, {1, 2}, {1, 1})
      |> should(eq {:error, "line already drawn from {1, 2} to {1, 1}"})
    end

    it "does not fill the line if it does not exist" do
      BoardLines.new(3)
      |> BoardLines.fill_line(user, {2, 2}, {2, 3})
      |> should(eq {:error, "line does not exist from {2, 2} to {2, 3}"})

      BoardLines.new(3)
      |> BoardLines.fill_line(user, {2, 3}, {2, 2})
      |> should(eq {:error, "line does not exist from {2, 3} to {2, 2}"})
    end

    it "does not fill the line if it's more than 1 unit long" do
      BoardLines.new(3)
      |> BoardLines.fill_line(user, {2, 0}, {0, 0})
      |> should(eq {:error, "line is more than one unit long from {2, 0} to {0, 0}"})

      BoardLines.new(3)
      |> BoardLines.fill_line(user, {0, 2}, {0, 0})
      |> should(eq {:error, "line is more than one unit long from {0, 2} to {0, 0}"})

      BoardLines.new(3)
      |> BoardLines.fill_line(user, {0, 0}, {2, 0})
      |> should(eq {:error, "line is more than one unit long from {0, 0} to {2, 0}"})

      BoardLines.new(3)
      |> BoardLines.fill_line(user, {0, 0}, {0, 2})
      |> should(eq {:error, "line is more than one unit long from {0, 0} to {0, 2}"})
    end

    it "does not fill the line if it is diagonal" do
      BoardLines.new(3)
      |> BoardLines.fill_line(user, {0, 0}, {1, 1})
      |> should(eq {:error, "cannot draw line in unknown direction from {0, 0} to {1, 1}"})

      BoardLines.new(3)
      |> BoardLines.fill_line(user, {1, 1}, {0, 0})
      |> should(eq {:error, "cannot draw line in unknown direction from {1, 1} to {0, 0}"})
    end

    it "does not fill the line if it's itself" do
      BoardLines.new(3)
      |> BoardLines.fill_line(user, {2, 2}, {2, 2})
      |> should(eq {:error, "line is to itself from {2, 2} to {2, 2}"})
    end
  end

  describe "line_direction(from, to)" do
    it "returns :vertical when the two points share the same x value" do
      BoardLines.line_direction({1, 1}, {1, 2}) |> should(eq :vertical)
    end

    it "returns :horizontal when the two points share the same y value" do
      BoardLines.line_direction({3, 1}, {1, 1}) |> should(eq :horizontal)
    end

    it "returns unknown when the line is neither vertical nor horizontal" do
      BoardLines.line_direction({3, 1}, {1, 2}) |> should(eq :unknown)
    end
  end

  describe "line_filled?(board_lines, from, to)" do
    it "is true if the line has been filled" do
      {:ok, board_lines} = BoardLines.new(3)
                            |> BoardLines.fill_line(user, {1, 2}, {2, 2})

      board_lines
      |> BoardLines.line_filled?({1, 2}, {2, 2})
      |> should(eq true)

      board_lines
      |> BoardLines.line_filled?({2, 2}, {1, 2})
      |> should(eq true)
    end

    it "is true if the line has not been filled" do
      board_lines = BoardLines.new(3)

      board_lines
      |> BoardLines.line_filled?({1, 2}, {2, 2})
      |> should(eq false)

      board_lines
      |> BoardLines.line_filled?({4, 4}, {4, 5})
      |> should(eq false)
    end
  end
end
