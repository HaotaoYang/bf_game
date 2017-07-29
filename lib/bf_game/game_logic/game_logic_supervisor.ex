defmodule GameLogic.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :game_logic_sup)
  end

  def init([]) do
    children = [worker(GameLogic, [], restart: :transient)]
    supervise children, strategy: :one_for_one
  end
end
