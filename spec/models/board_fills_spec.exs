defmodule DotsServer.BoardFillsSpec do
  use ESpec

  alias DotsServer.BoardFills

  import DotsServer.Factory

  let :user, do: create(:user)

  let :board_fills_data, do: Poison.encode!(board_fills)
  let :board_fills do
    [
      [nil, nil, nil],
      [nil, nil, nil],
      [nil, nil, nil]
    ]
  end

  describe "new(board_size)" do
    it "returns a new board_fills for a size x size board" do
      expected = [
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil],
        [nil, nil, nil, nil]
      ]
      BoardFills.new(5) |> should(eq expected)
    end
  end

  describe "parse(board_fills_data)" do
    it "returns a parsed board_fills object" do
      board_fills_data
      |> BoardFills.parse
      |> should(eq board_fills)
    end
  end

  describe "data(board_fills)" do
    it "encodes a board_fills object as string data" do
      board_fills
      |> BoardFills.data
      |> should(eq board_fills_data)
    end
  end

  describe "fill_block(board_fills, origin)" do
    it "fills the block for the user if it exists" do
      expected = {:ok, [
        [nil, nil, nil],
        [nil, nil, nil],
        [nil, user.id, nil]
      ]}

      board_fills
      |> BoardFills.fill_block(user, {1, 2})
      |> should(eq expected)
    end

    it "does not allow a block to be filled twice" do
      {:ok, board_fills} = board_fills |> BoardFills.fill_block(user, {1, 2})

      {:error, msg} = board_fills |> BoardFills.fill_block(user, {1, 2})

      msg |> should(eq "board_fills is already filled at origin_point {1, 2}")
    end

    it "does not allow a nonexistent block to be filled" do
      {:error, msg} = board_fills
                      |> BoardFills.fill_block(user, {4, 4})

      msg |> should(eq "board_fills does not contain origin_point {4, 4}")
    end
  end
end
