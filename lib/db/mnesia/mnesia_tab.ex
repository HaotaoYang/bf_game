defmodule MnesiaTab do

  use GenServer
  require Logger

  @save_data_interval_sec 300

  ## =================================================================
  ## api
  ## =================================================================
  def start_link(table_name, table_opts) do
    GenServer.start_link(__MODULE__, [table_name, table_opts], name: where_is(table_name))
  end

  def where_is(table_name) do
    {:via, Registry, {MyRegistry, "mnesia_" <> to_string(table_name)}}
  end

  def insert_or_save(table_name, data) do
    GenServer.cast(where_is(table_name), {:insert_or_save, data})
  end

  def delete(table_name, key) do
    GenServer.cast(where_is(table_name), {:delete, key})
  end

  def offline_save(table_name, data) do
    GenServer.cast(where_is(table_name), {:offline_save, data})
  end

  def lookup(table_name, key) do
    GenServer.call(where_is(table_name), {:lookup, key})
  end

  def get_auto_increment_id(table_type) do
    GenServer.call(where_is(:auto_increment_id_tab), {:get_auto_increment_id, table_type})
  end

  ## =================================================================
  ## callback
  ## =================================================================
  def init([table_name, table_opts]) do
    Process.flag(:trap_exit, true)
    %{attributes: attributes, type: type, load_all: load_all} = table_opts
    disc_type = case load_all do
      true -> :disc_copies
      _ ->
        :ets.new(table_name, [:set, :public, :named_table, {:write_concurrency, false}, {:read_concurrency, true}, {:keypos, 2}])
        start_save_data_timer()
        :disc_only_copies
    end
    new_table_opts =
    Keyword.new()
    |> Keyword.put(:record_name, table_name)
    |> Keyword.put(:attributes, attributes)
    |> Keyword.put(:type, type)
    |> Keyword.put(disc_type, [node()])
    case exist?(table_name) do
      true ->
        case wait([table_name], :infinity) do
          :ok ->
            old_attributes = :mnesia.table_info(table_name, :attributes)
            case attributes == old_attributes do
              true -> Logger.debug "table #{inspect(table_name)} load successfully..."
              _ -> change_attribute(table_name, attributes)
            end
          _ ->
            Logger.error "table #{inspect(table_name)} is unaccessible..."
        end
      _ ->
        create(table_name, new_table_opts)
    end
    state = %{
      table_name: table_name,
      table_opts: table_opts
    }
    {:ok, state}
  end

  def handle_call({:lookup, key}, _from, %{table_name: table_name} = state) do
    ret = case :ets.lookup(table_name, key) do
      [data] -> [data]
      _ ->
        case :mnesia.dirty_read(table_name, key) do
          [data] ->
            :ets.insert(table_name, data)
            [data]
          _ ->
            []
        end
    end
    {:reply, ret, state}
  end
  def handle_call({:get_auto_increment_id, table_type}, _from, %{table_name: table_name} = state) do
    # ret = :mnesia.dirty_update_counter(table_name, table_type, 1)
    ret = :ets.update_counter(table_name, table_type, 1, {table_name, table_type, 0})
    save_ets_data(table_name)
    {:reply, ret, state}
  end
  def handle_call(msg, _from, state) do
    Logger.warn "mnesia_tab: #{inspect state.table_name} receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, state}
  end

  def handle_cast({:insert_or_save, data}, %{table_name: table_name, table_opts: %{load_all: load_all}} = state) do
    case load_all do
      true -> :ets.insert(table_name, data)
      _ ->
        :ets.insert(table_name, data)
        :mnesia.dirty_write(table_name, data)
    end
    {:noreply, state}
  end
  def handle_cast({:delete, key}, %{table_name: table_name, table_opts: %{load_all: load_all}} = state) do
    case load_all do
      true ->
        :ets.delete(table_name, key)
      _ ->
        :ets.delete(table_name, key)
        :mnesia.dirty_delete(table_name, key)
    end
    {:noreply, state}
  end
  def handle_cast({:offline_save, data}, %{table_name: table_name, table_opts: %{load_all: load_all}} = state) do
    case load_all do
      true -> :ok
      _ ->
        :mnesia.dirty_write(table_name, data)
        :ets.delete(table_name, elem(data, 1))
    end
    {:noreply, state}
  end
  def handle_cast(msg, state) do
    Logger.warn "mnesia_tab: #{inspect state.table_name} receive an unknown cast msg:#{inspect msg}"
    {:noreply, state}
  end

  def handle_info(:save_data, %{table_name: table_name} = state) do
    save_ets_data(table_name)
    start_save_data_timer()
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.warn "mnesia_tab: #{inspect state.table_name} receive an unknown info msg:#{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, %{table_name: table_name}) do
    Logger.error "mnesia_tab: #{inspect table_name} terminate, reason: #{inspect reason}"
    save_ets_data(table_name)
    :ok
  end

  ## =================================================================
  ## private
  ## =================================================================
  defp create(table_name, table_opts) do
    case :mnesia.create_table(table_name, table_opts) do
      {:atomic, :ok} ->
        Logger.debug "table #{inspect(table_name)} create successfully..."
      err->
        Logger.error "table #{inspect(table_name)} create err: #{inspect(err)}"
    end
  end

  defp exist?(table_name) do
    :mnesia.system_info(:tables) |> Enum.member?(table_name)
  end

  defp wait(names, timeout) do
    :mnesia.wait_for_tables(names, timeout)
  end

  defp save_ets_data(table_name) do
    Enum.each(
      :ets.tab2list(table_name),
      fn(data) ->
        :mnesia.dirty_write(table_name, data)
      end
    )
  end

  defp start_save_data_timer() do
    Process.send_after(self(), :save_data, @save_data_interval_sec * 1000)
  end

  defp change_attribute(table_name, new_attributes) do
    new_attributes_tuple = List.to_tuple([table_name | new_attributes])
    :mnesia.transform_table(table_name,
      fn(a) ->
        change_d(a, new_attributes_tuple)
      end,
      new_attributes, 
      table_name
    ) 
  end

  defp change_d(old_data, new_attributes_tuple) do
    size = tuple_size(new_attributes_tuple)
    do_change_d(size, 1, old_data, new_attributes_tuple)
  end
  defp do_change_d(size, _index, old_data, new_attributes_tuple) when size == 1 do
    e = get_v(old_data, size)
    put_elem(new_attributes_tuple, size, e)
  end
  defp do_change_d(size, index, old_data, new_attributes_tuple) do
    e = get_v(old_data, index)
    do_change_d(size-1, index+1, old_data, put_elem(new_attributes_tuple, index, e))
  end

  defp get_v(old_data, index) do
    size = tuple_size(old_data)
    if index > size-1 do
      nil
    else
      elem(old_data, index)
    end
  end

end
