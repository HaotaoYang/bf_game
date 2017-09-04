defmodule MQ.Sender do

  use GenServer
  use AMQP
  require Logger

  @queue_name   "hb_2_api"

  ## =================================================================
  ## api
  ## =================================================================
  def start_link(mq_conn) do
    GenServer.start_link(__MODULE__, [mq_conn], name: :sender)
  end

  ## 向mq队列发送消息，这里会阻塞直到接受到返回消息
  def send_msg(registry_key, msg) do
    encode_msg = Poison.encode!(msg)
    GenServer.cast(:sender, {:send_msg, encode_msg})
    receive do
      {:ok, ret} ->
        Registry.unregister(MqRegistry, registry_key)
        {:ok, ret}
      _ ->
        :error
    after
      5000 ->
        :error
    end
  end

  ## =================================================================
  ## callback
  ## =================================================================
  def init([mq_conn]) do
    Process.flag(:trap_exit, true)
    Process.monitor(mq_conn.pid)
    chan = open_channel(mq_conn)
    Logger.info("mq open sender channel...")
    {:ok, chan}
  end

  def handle_call(msg, _from, chan) do
    Logger.warn "mq sender receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, chan}
  end

  def handle_cast({:send_msg, encode_msg}, chan) do
    Basic.publish(chan, "", @queue_name, encode_msg)
    {:noreply, chan}
  end
  def handle_cast(msg, chan) do
    Logger.warn "mq sender receive an unknown cast msg:#{inspect msg}"
    {:noreply, chan}
  end

  def handle_info({:DOWN, _, :process, _pid, _reason}, chan) do
    Logger.error "mq sender connection terminate..."
    {:noreply, chan}
  end
  def handle_info({:basic_consume_ok, _}, chan) do
    {:noreply, chan}
  end
  def handle_info(msg, chan) do
    Logger.warn "mq sender receive an unknown message: #{inspect msg}"
    {:noreply, chan}
  end

  def terminate(reason, _chan) do
    Logger.error "mq sender terminate, reason: #{inspect reason}"
    :ok
  end

  ## =================================================================
  ## private
  ## =================================================================
  defp open_channel(mq_conn) do
    {:ok, chan} = Channel.open(mq_conn)
    Queue.declare(chan, @queue_name, durable: true)
    chan
  end

end
