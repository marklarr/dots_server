defmodule DotsServer.GameBoardChannel do
  use DotsServer.Web, :channel

  def join("game_boards:play", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("status", payload, socket) do
    {:reply, {:ok, %{board: "status"}}, socket}
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
