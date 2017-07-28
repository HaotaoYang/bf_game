defmodule UserMng.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :user_mng_sup)
  end

  def start_child(user_id, user_name, chip) do
    Supervisor.start_child(:user_mng_sup, [{user_id, user_name, chip}])
  end

  def init([]) do
    children = [worker(UsersMng, [], restart: :temporary)]
    supervise children, strategy: :simple_one_for_one
  end
end
