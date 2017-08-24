defmodule BfGame.UserSocket do
  use Phoenix.Socket
  require Logger

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
  def connect(%{"token" => token}, socket) do
    case get_user_info(token) do
      %{user_id: user_id, user_name: user_name, chip: chip} = info ->
        case user_login(info) do
          {:ok, _order} ->
            case create_user(user_id, user_name, chip) do
              :ok -> {:ok, assign(socket, :user_id, user_id)}
              _ -> :error
            end
          _ ->
            :error
        end
      _ ->
        :error
    end
  end
  def connect(%{"secret" => secret}, socket) do
    case Tools.verify_secret(secret) do
      {:ok, user_id} ->
        case UserMng.is_user_alive?(user_id) do
          true -> {:ok, assign(socket, :user_id, user_id)}
          _ -> :error
        end
      _ -> :error
    end
  end

  defp get_user_info(token) do
    case Tools.get_env(:start_env) do
      :prod ->	## 生产环境
		case Platform.HttpHandler.post(token) do
          {:ok, info} -> info
          _ -> :error
        end
      _ ->
        user_id = case is_integer(token) do
          true -> token
          _ -> :erlang.phash2(token, 100_000)
        end
		%{
		  user_id: user_id,
		  user_name: "user_#{user_id}",
		  chip: 100000
		}
    end
  end

  defp user_login(info) do
    case Tools.get_env(:start_env) do
      :prod ->  ## 生产环境
        {:ok, _} = Registry.register(MqRegistry, user_id, "")
        msg = %{
          action: "login",
          user_id: info.user_id
        }
		MQ.Sender.send_msg(msg)
      _ ->
        {:ok, 0}
    end
  end

  defp create_user(user_id, user_name, chip) do
    case UserMng.Supervisor.start_child(user_id, user_name, chip) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} ->
        UserMng.kickout_user(user_id)
        :timer.sleep(1000)
        UserMng.Supervisor.start_child(user_id, user_name, chip)
        :ok
      e ->
        Logger.error "user: #{user_id} progress start faild, reason: #{inspect(e)}"
        :error
    end
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
