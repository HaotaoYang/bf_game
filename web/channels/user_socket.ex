defmodule BfGame.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "lobby:*", BfGame.LobbyChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"user_token" => token}, socket) do
    %{user_id: user_id, user_name: user_name} = get_user_info(token)
    {
      :ok,
      socket
      |> assign(:user_id, user_id)
      |> assign(:user_name, user_name)
    }
  end

  def get_user_info(token) do
    user_id = case is_integer(token) do
      true -> token
      _ -> :erlang.phash2(token, 100_000)
    end
    %{
      user_id: user_id,
      user_name: "user_#{user_id}"
    }
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     BfGame.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
