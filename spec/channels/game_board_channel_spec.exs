defmodule DotsServer.GameBoardChannelTest do
  use ESpec
  use DotsServer.ChannelCase

  alias DotsServer.GameBoardChannel

  import DotsServer.Factory

  let :game_board, do: create(:game_board) |> with_users
  let :user1, do: Enum.at(game_board.users, 0)
  let :user2, do: Enum.at(game_board.users, 1)
  let :socket1 do
    {:ok, _, socket} =
      socket("users_socket", %{user_id: user1.id})
      |> subscribe_and_join(GameBoardChannel, "game_boards:play", %{"id": game_board.id})
    socket
  end
  let :socket2 do
    {:ok, _, socket} =
    socket("users_socket", %{user_id: user2.id})
    |> subscribe_and_join(GameBoardChannel, "game_boards:play", %{"id": game_board.id})
    socket
  end

  it "ping replies with status ok" do
    ref = push socket1, "status"
    assert_reply ref, :ok, %{board: "status"}
  end

  it "take_turn broadcasts to game_boards:play" do
    push socket1, "take_turn"
    assert_broadcast "turn taken!", %{board: "hey"}
  end

  it "broadcasts are pushed to the client" do
    broadcast_from! socket1, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
