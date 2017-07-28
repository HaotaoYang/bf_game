defmodule GameLogic do

  use GenServer
  require Logger

  @doc """
  Start game_logic worker.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: :game_logic])
  end

  def init(args) do
    Logger.debug "=================#{inspect args}==============="
    game_state = %GameState{}
    {:ok, game_state}
  end

  def handle_call(msg, _from, state) do
    Logger.warn "game_logic receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, state}
  end

  def handle_cast(msg, state) do
    Logger.warn "game_logic receive an unknown cast msg:#{inspect msg}"
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.warn "game_logic receive an unknown info msg:#{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.debug "game_logic process terminate, reason: #{inspect reason}"
    state
  end

  ## =================================================================
  ## private
  ## =================================================================

end
