defmodule MnesiaTab.Supervisor do

  use Supervisor
  require Logger

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: :mnesia_tab_sup)
  end

  def init([]) do
    Application.ensure_started(:mnesia)
    init_schema()
    table_list = MnesiaApi.table_list()
    children = for %{record_name: table_name} = table_opts <- table_list do
      worker(MnesiaTab, [table_name, table_opts], [restart: :permanent, id: {MnesiaTab, table_name}])
    end
    supervise children, strategy: :one_for_one
  end

  defp init_schema() do
    case :mnesia.table_info(:schema, :disc_copies) do
      [] ->
        :mnesia.change_table_copy_type(:schema, node(), :disc_copies)
      _ ->
        :ok
    end
    # Application.stop(:mnesia)
    # dir_name = List.to_string(:mnesia.system_info(:directory)) <> "/"
    # case :filelib.ensure_dir(dir_name) do
    #   :ok ->
    #     {:ok, file_list} = :file.list_dir(dir_name)
    #     case file_list == [] do
    #       true ->
    #         case :mnesia.create_schema([node()]) do
    #           :ok -> Logger.debug "create schema successfully..."
    #           err -> Logger.error "create schema failed, err:#{inspect(err)}"
    #         end
    #       _ -> 
    #         Logger.debug "init schema successfully..."
    #         :ok
    #     end
    #   {:error, reason} ->
    #     Logger.error "mnesia dir error: #{inspect(reason)}"
    # end
  end

end
