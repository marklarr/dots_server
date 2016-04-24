defmodule DotsServer.GameBoardChannel do
  use DotsServer.Web, :channel

  import Phoenix.Socket

  alias DotsServer.GameBoard
  alias DotsServer.User
  alias DotsServer.GameEngine

  def join("game_boards:" <> game_board_id, payload, socket) do
    if authorized?(payload) do
      {:ok, assign(socket, :game_board_id, String.to_integer(game_board_id))}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("status", _payload, socket) do
    return_payload = game_board(socket)
                      |> response_payload

    {:reply, {:ok, return_payload}, socket}
  end

  def handle_in("take_turn", payload, socket) do
    game_board = game_board(socket)
    user = user(socket)
    {from, to} = from_to(payload)

    case GameEngine.draw_line(game_board, user, from, to) do
      {:ok, game_board} ->
        broadcast socket, "updated_game_board", response_payload(game_board)
        {:reply, :ok, socket}
      {:error, _msg} ->
        {:reply, :error, socket}
    end
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

  defp response_payload(game_board) do
    %{"game_board" => Poison.decode!(Poison.encode!(game_board))}
  end

  defp game_board(socket) do
    DotsServer.Repo.get(GameBoard, socket.assigns.game_board_id)
  end

  defp user(socket) do
    DotsServer.Repo.get(User, socket.assigns.user_id)
  end

  defp from_to(payload) do
    [from, to] = Enum.map [:from, :to], fn(key) ->
      coordinate_map = Map.get(payload, key)
      x = Map.get(coordinate_map, :x)
      y = Map.get(coordinate_map, :y)
      {x, y}
    end

    {from, to}
  end
end
