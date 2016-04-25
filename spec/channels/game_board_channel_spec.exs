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
      |> subscribe_and_join(GameBoardChannel, "game_boards:#{game_board.id}")
    socket
  end
  let :socket2 do
    {:ok, _, socket} =
      socket("users_socket", %{user_id: user2.id})
      |> subscribe_and_join(GameBoardChannel, "game_boards:#{game_board.id}")
    socket
  end

  describe "status" do
    it "returns the current status of the game_board" do
      expected_game_board = %{
        "game_board" => %{
          "id" => game_board.id,
          "board_lines" => [
            [nil, nil],
            [nil, nil, nil],
            [nil, nil],
            [nil, nil, nil],
            [nil, nil]
          ],
          "board_fills" => [
            [nil, nil],
            [nil, nil]
          ],
          "users" => [
            %{
              "id" => user1.id,
              "handle" => user1.handle,
              "email" => user1.email
            },
            %{
              "id" => user2.id,
              "handle" => user2.handle,
              "email" => user2.email
            }
          ],
          "next_turn_user" => %{
            "id" => user1.id,
            "handle" => user1.handle,
            "email" => user1.email
          }
        }
      }

      ref = push socket1, "status"
      assert_reply(ref, :ok, actual_game_board)
      actual_game_board |> should(eq expected_game_board)
    end
  end

  describe "take_turn" do
    context "valid move" do
      it "takes the turn and broadcasts the new game_board to all sockets" do
          expected_game_board = %{
              "game_board" => %{
                  "id" => game_board.id,
                  "board_lines" => [
                      [nil, nil],
                      [nil, nil, nil],
                      [nil, nil],
                      [nil, user1.id, nil],
                      [nil, nil]
                    ],
                  "board_fills" => [
                      [nil, nil],
                      [nil, nil]
                    ],
                  "users" => [
                      %{
                          "id" => user1.id,
                          "handle" => user1.handle,
                          "email" => user1.email
                        },
                      %{
                          "id" => user2.id,
                          "handle" => user2.handle,
                          "email" => user2.email
                        }
                    ],
                  "next_turn_user" => %{
                      "id" => user2.id,
                      "handle" => user2.handle,
                      "email" => user2.email
                    }
                }
            }

          push socket1, "take_turn", %{from: %{x: 1, y: 1 }, to: %{x: 1, y: 2} }
          assert_broadcast "updated_game_board", actual_game_board
          actual_game_board |> should(eq expected_game_board)
        end

      it "replies with status ok" do
        ref = push socket1, "take_turn", %{from: %{x: 1, y: 1 }, to: %{x: 1, y: 2} }
        assert_broadcast "updated_game_board", _
        assert_reply(ref, :ok, _)
      end
    end

    context "invalid move" do
      it "does not broadcast anything to the sockets" do
        push socket1, "take_turn", %{from: %{x: 1, y: 1 }, to: %{x: 2, y: 2} }
        refute_broadcast "updated_game_board", _
      end

      it "replies with a status of error and the reason" do
        ref = push socket1, "take_turn", %{from: %{x: 1, y: 1 }, to: %{x: 2, y: 2} }
        assert_reply(ref, :error, %{reason: "cannot draw line in unknown direction from {1, 1} to {2, 2}"})
      end
    end
  end

  describe "subscribe_and_join" do
    context "user not a part of game" do
      it "returns an 'unauthorized' error" do
        user3 = create(:user)
        {:error, message} = socket("users_socket", %{user_id: user3.id})
                            |> subscribe_and_join(GameBoardChannel, "game_boards:#{game_board.id}")
        message |> should(eq %{reason: "unauthorized"})
      end
    end

    context "no GameBoard with provided id exists" do
      it "returns an error" do
        {:error, message} = socket("users_socket", %{user_id: user1.id})
                            |> subscribe_and_join(GameBoardChannel, "game_boards:99999")
        message |> should(eq %{reason: "cannot find game_board with id 99999"})
      end
    end
  end

  describe "broadcast" do
    it "pushes to the client" do
      broadcast_from! socket1, "broadcast", %{"some" => "data"}
      assert_push "broadcast", %{"some" => "data"}
    end
  end
end
