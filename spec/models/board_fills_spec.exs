defmodule DotsServer.BoardFillsSpec do
  use ESpec
  alias DotsServer.BoardFills

  let :board_fills_data, do: Poison.encode!(board_fills)
  let :board_fills do
    [
      [:empty, :empty, :empty],
      [:empty, :empty, :empty],
      [:empty, :empty, :empty]
    ]
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
    it "fills the block if it exists" do
      expected = [
        [:empty, :empty, :empty],
        [:empty, :filled, :empty],
        [:empty, :empty, :empty]
      ]

      board_fills
      |> BoardFills.fill_block({1, 1})
      |> should(eq expected)
    end

    it "does not allow a block to be filled twice" do
      {:error, msg} = board_fills
                      |> BoardFills.fill_block({1, 1})
                      |> BoardFills.fill_block({1, 1})

      msg |> should(eq "board_fills is already filled at origin_point (1, 1)")
    end

    it "does not allow a nonexistent block to be filled" do
      {:error, msg} = board_fills
                      |> BoardFills.fill_block({4, 4})

      msg |> should(eq "board_fills does not contain origin_point (4, 4)")
    end
  end
end
