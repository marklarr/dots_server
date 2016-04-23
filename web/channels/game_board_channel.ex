defmodule DotsServer.GameBoardChannel do
  use DotsServer.Web, :channel

  import Phoenix.Socket

  alias DotsServer.GameBoard
  alias DotsServer.BoardLines
  alias DotsServer.BoardFills
  alias DotsServer.GameEngine

  def join("game_boards:" <> game_board_id, payload, socket) do
    if authorized?(payload) do
      {:ok, assign(socket, :game_board_id, String.to_integer(game_board_id))}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("status", _payload, socket) do
    game_board = DotsServer.Repo.get(GameBoard, socket.assigns.game_board_id)
                  |> DotsServer.Repo.preload([:users, :next_turn_user])

    user1 = Enum.at(game_board.users, 0)
    user2 = Enum.at(game_board.users, 1)

    game_board_payload = %{
      game_board: %{
        id: game_board.id,
        board_lines: game_board.board_lines_data |> BoardLines.parse,
        board_fills: game_board.board_fills_data |> BoardFills.parse,
        users: [
          %{
            id: user1.id,
            handle: user1.handle,
            email: user1.email
          },
          %{
            id: user2.id,
            handle: user2.handle,
            email: user2.email
          }
        ],
        next_turn_user: %{
          id: game_board.next_turn_user.id,
          handle: game_board.next_turn_user.handle,
          email: game_board.next_turn_user.email
        }
      }
    }

    {:reply, {:ok, game_board_payload}, socket}
  end

  def handle_in("take_turn", payload, socket) do
    game_board = DotsServer.Repo.get(GameBoard, socket.assigns.game_board_id)
                  |> DotsServer.Repo.preload([:users, :next_turn_user])

    user1 = Enum.at(game_board.users, 0)
    user2 = Enum.at(game_board.users, 1)

    #FIXME: user1 is hardcoded
    [from, to] = Enum.map [:from, :to], fn(key) ->
      coordinate_map = Map.get(payload, key)
      x = Map.get(coordinate_map, :x)
      y = Map.get(coordinate_map, :y)
      {x, y}
    end
    {:ok, game_board} = GameEngine.draw_line(game_board, user1, from, to)

    game_board_payload = %{
      game_board: %{
        id: game_board.id,
        board_lines: game_board.board_lines_data |> BoardLines.parse,
        board_fills: game_board.board_fills_data |> BoardFills.parse,
        users: [
          %{
            id: user1.id,
            handle: user1.handle,
            email: user1.email
          },
          %{
            id: user2.id,
            handle: user2.handle,
            email: user2.email
          }
        ],
        next_turn_user: %{
          id: game_board.next_turn_user.id,
          handle: game_board.next_turn_user.handle,
          email: game_board.next_turn_user.email
        }
      }
    }
    broadcast socket, "updated_game_board", game_board_payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
