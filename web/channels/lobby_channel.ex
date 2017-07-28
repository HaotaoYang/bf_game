defmodule BfGame.LobbyChannel do
  use BfGame.Web, :channel
  require Logger

  def join("lobby:channel", _payload, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def handle_in(command, payload, socket) do
    IO.inspect {command, payload}, label: "receive a unknown msg from client"
    {:noreply, socket}
  end

  @doc """
  client exit current channel
  client leave: reason: {:shutdown, :left}
  client close: reason: {:shutdown, :close}
  """
  def terminate(_reason, socket) do
    Logger.debug "user_id:#{socket.assigns.user_id} lobby channel terminate!!"
    :ok
  end

  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end

  def handle_info(msg, state) do
    IO.inspect msg, label: "lobby channel receive a unknown info msg"
    {:noreply, state}
  end

end
