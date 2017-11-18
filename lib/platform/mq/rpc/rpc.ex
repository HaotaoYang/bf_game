defmodule MQ.RPC do

  use GenServer
  use AMQP
  require Logger

  defstruct [:index, :chan]

  @queue_name   "api_rpc_hb"
  @qos          1

  ## =================================================================
  ## api
  ## =================================================================
  def start_link(args) do
    GenServer.start_link(__MODULE__, [args])
  end

  ## =================================================================
  ## callback
  ## =================================================================
  def init([{mq_conn, n}]) do
    Process.flag(:trap_exit, true)
    Process.monitor(mq_conn.pid)
    chan = open_channel(mq_conn)
    Logger.info("mq open no.#{n} rpc channel...")
    state = %MQ.RPC{
      index: n,
      chan: chan
    }
    {:ok, state}
  end

  def handle_call(msg, _from, state) do
    Logger.warn "mq rpc receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, state}
  end

  def handle_cast(msg, state) do
    Logger.warn "mq rpc receive an unknown cast msg:#{inspect msg}"
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta}, %{index: n, chan: chan} = state) do
    Logger.debug "mq rpc process index:#{n} receive msg: #{inspect(payload)}"
    case Poison.decode(payload) do
      {:ok, msg} ->
        case handle_msg(msg) do
          {:ok, reply} ->
            response = Poison.encode!(reply)
            Basic.publish(chan, "", meta.reply_to, "#{response}", correlation_id: meta.correlation_id)
            :ok
          _ ->
            :ok
        end
      err ->
        Logger.error("mq rpc decode payload error: #{inspect err}")
        :ok
    end
    Basic.ack(chan, meta.delivery_tag)
    {:noreply, state}
  end
  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    Logger.error "mq rpc connection terminate..."
    {:noreply, state}
  end
  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.warn "mq rpc receive an unknown message: #{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, _chan) do
    Logger.error "mq rpc terminate, reason: #{inspect reason}"
    :ok
  end

  ## =================================================================
  ## private
  ## =================================================================
  defp open_channel(mq_conn) do
    {:ok, chan} = Channel.open(mq_conn)
    Queue.declare(chan, @queue_name, durable: true)
    Basic.qos(chan, prefetch_count: @qos)
    Basic.consume(chan, @queue_name)
    chan
  end

  # defp handle_msg(%{"action" => "kick", "uid" => uid, "order_id" => order_id}) do
  #   {:ok, %{code: 0, msg: %{coin: -1, online_flg: 1, time: :os.system_time(1)}}}
  # end
  defp handle_msg(msg) do
    Logger.error("mq rpc handle_msg error, msg:#{inspect(msg)}")
    :error
  end

end
