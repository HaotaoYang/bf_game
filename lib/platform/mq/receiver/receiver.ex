defmodule MQ.Receiver do

  use GenServer
  use AMQP
  require Logger

  defstruct [:index, :chan]

  @queue_name   "api_2_hb"
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
    Logger.info("mq open no.#{n} receiver channel...")
    state = %MQ.Receiver{
      index: n,
      chan: chan
    }
    {:ok, state}
  end

  def handle_call(msg, _from, state) do
    Logger.warn "mq receiver receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, state}
  end

  def handle_cast(msg, state) do
    Logger.warn "mq receiver receive an unknown cast msg:#{inspect msg}"
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta}, %{index: n, chan: chan} = state) do
    Logger.debug "mq receiver process index:#{n} receive msg: #{inspect(payload)}"
    case Poison.decode(payload) do
      {:ok, msg} ->
        handle_msg(msg)
        :ok
      err ->
        Logger.error("mq receiver decode payload error: #{inspect err}")
        :ok
    end
    Basic.ack(chan, meta.delivery_tag)
    {:noreply, state}
  end
  def handle_info({:DOWN, _, :process, _pid, _reason}, state) do
    Logger.error "mq receiver connection terminate..."
    {:noreply, state}
  end
  def handle_info({:basic_consume_ok, _}, state) do
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.warn "mq receiver receive an unknown message: #{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, _chan) do
    Logger.error "mq receiver terminate, reason: #{inspect reason}"
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

  defp handle_msg(%{"action" => "login_reply", "uid" => user_id, "order_id" => order_id}) do
    pid = where(user_id)
    case is_pid(pid) do
      true -> send(pid, {:ok, order_id})
      _ ->
        Logger.error("can not find mq sender pid")
        :error
    end
  end
  # defp handle_msg(%{"action" => "robots_reply", "data" => robot_info, "pid" => pid}) do
  #   pid = :erlang.list_to_pid(:erlang.bitstring_to_list(pid))
  #   send pid, {:get_robots, robot_info}
  # end
  defp handle_msg(_msg) do
    :error
  end

  defp where(user_id) do
    case Registry.lookup(MqRegistry, user_id) do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

end
