defmodule DotsServer.GameBoardChannel do
  use DotsServer.Web, :channel

  import Phoenix.Socket

  alias DotsServer.GameBoard

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
        board_lines: [
          [nil, nil],
          [nil, nil, nil],
          [nil, nil],
          [nil, nil, nil],
          [nil, nil]
        ],
        board_fills: [
          [nil, nil],
          [nil, nil]
        ],
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

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game_boards:lobby).
  def handle_in("take_turn", payload, socket) do
    broadcast socket, "turn taken!", %{board: "hey"}
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
