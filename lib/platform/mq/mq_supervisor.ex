defmodule MQ.Supervisor do

  use Supervisor
  use AMQP
  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :mq_sup)
  end

  def init([]) do
    children = case rabbitmq_connect() do
      {:ok, conn} ->
        Logger.info "mq connect successful..."
        sender_worker = [worker(MQ.Sender, [conn], restart: :permanent)]
        receiver_worker = for n <- 1..8 do
          worker(MQ.Receiver, [{conn, n}], [restart: :permanent, id: {:receiver, n}])
        end
        rpc_worker = for n <- 1..8 do
          worker(MQ.RPC, [{conn, n}], [restart: :permanent, id: {:rpc, n}])
        end
        sender_worker ++ receiver_worker ++ rpc_worker
      _ ->
        Logger.error "mq connect failed..."
        []
    end
    supervise children, strategy: :one_for_one
  end

  defp rabbitmq_connect() do
    case Tools.get_env(:queue_args) do
      nil ->
        Logger.error("can not get mq config, can not start mq process")
        :error
      queue_args ->
        Connection.open(queue_args)
    end
  end

end
