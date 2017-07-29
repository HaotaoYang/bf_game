defmodule UserMng do

  use GenServer
  require Logger

  ## =================================================================
  ## api
  ## =================================================================
  def start_link({user_id, _user_name, _chip} = args) do
    GenServer.start_link(__MODULE__, args, [name: where_is(user_id)])
  end

  def where_is(user_id) do
    {:via, Registry, {MyRegistry, "user_#{user_id}"}}
  end

  def is_user_alive?(user_id) do
    case Registry.lookup(MyRegistry, "user_#{user_id}") do
      [{pid, _}] -> Process.alive?(pid)
      _ -> false
    end
  end

  ## =================================================================
  ## callback
  ## =================================================================
  def init({user_id, user_name, chip}) do
    user_state = %UserState{
      user_id: user_id,
      user_name: user_name,
      chip: chip
    }
    {:ok, user_state}
  end

  def handle_call(msg, _from, state) do
    Logger.warn "user:#{state.user_id} receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, state}
  end

  def handle_cast(msg, state) do
    Logger.warn "user:#{state.user_id} receive an unknown cast msg:#{inspect msg}"
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warn "user:#{state.user_id} receive an unknown info msg:#{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, %{user_id: user_id}) do
    Logger.debug "user:#{user_id} terminate, reason: #{inspect reason}"
    :ok
  end

  ## =================================================================
  ## private
  ## =================================================================

end
