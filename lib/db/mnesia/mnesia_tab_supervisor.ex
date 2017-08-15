defmodule MnesiaTab.Supervisor do

  use Supervisor
  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :mnesia_tab_sup)
  end

  def start_child(table_name, table_opts) do
    Supervisor.start_child(:mnesia_tab_sup, [table_name, table_opts])
  end

  def init([]) do
    init_schema()
    children = [worker(MnesiaTab, [], restart: :permanent)]
    supervise children, strategy: :simple_one_for_one
  end

  defp init_schema() do
    dir_name = List.to_string(:mnesia.system_info(:directory)) <> "/"
    case :filelib.ensure_dir(dir_name) do
      :ok ->
        {:ok, file_list} = :file.list_dir(dir_name)
        case file_list == [] do
          true ->
            ret = :mnesia.create_schema([node()])
            Logger.debug "init db schema suc :   #{inspect(ret)}"
          _ -> 
            :ok
        end
        Logger.debug "init mnesia schema successfully..."
      {:error, reason} ->
        Logger.error "mnesia dir error: #{inspect(reason)}"
    end
  end

end
