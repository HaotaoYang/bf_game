defmodule MnesiaTab do

  use GenServer
  require Logger

  ## =================================================================
  ## api
  ## =================================================================
  def start_link(table_name, table_opts) do
    GenServer.start_link(__MODULE__, [table_name, table_opts], name: where_is(table_name))
  end

  def where_is(table_name) do
    {:via, Registry, {MyRegistry, "mnesia_" <> to_string(table_name)}}
  end

  ## =================================================================
  ## callback
  ## =================================================================
  def init([_table_name, _table_opts]) do
    # new_attributes = Keyword.get(table_opts, :attributes)
    # case Keyword.get(table_opts, :disc_only_copies) do
    #   nil ->
    #     :ok
    #   _ ->
    #     :ets.new(table_name, [:named_table, :public, {:keypos, 2}])
    # end
    # case TableUtil.exists?(table_name) do
    #   true ->
    #     old_attributes = :mnesia.table_info(table_name, :attributes)
    #     case TableUtil.wait([table_name], 5000) do
    #       :ok ->
    #         Logger.debug "#{inspect(table_name)}  table is load is ok"
    #       err ->
    #         Logger.error "table wait is #{inspect(err)}"
    #     end
    #     if new_attributes == old_attributes do
    #       :ok
    #     else
    #       change_attribute(table_name, old_attributes, new_attributes)
    #     end
    #   false ->
    #     create(table_name, table_opts)
    #     case Keyword.get(table_opts, :is_b) do
    #       false ->
    #         :ok
    #       true ->
    #         table_name2 = do_table_name(table_name, "2")
    #         table_opts = 
    #         table_opts 
    #           |> TableUtil.update(:record_name, table_name2)
    #           |> Keyword.delete(:disc_copies)
    #           |> TableUtil.update(:disc_only_copies, [node()])
    #         create(table_name2, table_opts)
    #     end
    # end
    # case Keyword.get(table_opts, :is_b) do
    #   true ->
    #     time = Util.get_now_to_24_remain_mes()
    #     Util.start_send_after(table_name, time, {:do_move_data, table_name, 10000})
    #   _ ->
    #     :ok
    # end
    {:ok, []}
  end

  def handle_call(msg, _from, state) do
    Logger.warn "mnesia_tab : #{inspect state} receive an unknown call msg:#{inspect msg}"
    {:reply, :ok, state}
  end

  def handle_cast(msg, state) do
    Logger.warn "mnesia_tab : #{inspect state} receive an unknown cast msg:#{inspect msg}"
    {:noreply, state}
  end

  # def handle_info({:do_move_data, table_name, count}, state) do
  #   TableUtil.move_data(table_name, count)
  #   {:noreply, state}
  # end
  def handle_info(msg, state) do
    Logger.warn "mnesia_tab : #{inspect state} receive an unknown info msg:#{inspect msg}"
    {:noreply, state}
  end

  def terminate(reason, state) do
    Logger.error "mnesia_tab : #{inspect state} terminate, reason: #{inspect reason}"
    :ok
  end

  ## =================================================================
  ## private
  ## =================================================================
  # defp create(table_name, table_opts) do
  #   table_opts = 
  #   table_opts
  #   |> Keyword.delete(:is_b)
  #   |> Keyword.delete(:is_limit)
  #   case :mnesia.create_table(table_name, table_opts) do
  #     {:atomic, :ok} ->
  #       Logger.debug "#{inspect(table_name)}  table is create is ok"
  #     err->
  #       Logger.error "#{inspect(table_name)}  table is create is #{inspect(err)}"
  #   end
  # end

  # defp change_attribute(table_name, _old_attributes, new_attributes) do
  #   new_attributes_tuple = List.to_tuple([table_name|new_attributes])
  #   :mnesia.transform_table(table_name,
  #     fn(a) ->
  #       change_d(a, new_attributes_tuple)
  #     end,
  #     new_attributes, 
  #     table_name) 
  # end

  # defp change_d(old_data, new_attributes_tuple) do
  #   size = tuple_size(new_attributes_tuple)
  #   do_change_d(size, 1, old_data, new_attributes_tuple)
  # end
  # defp do_change_d(size, _index, old_data, new_attributes_tuple) when size == 1 do
  #   e = get_v(old_data, size)
  #   put_elem(new_attributes_tuple, size, e)
  # end
  # defp do_change_d(size, index, old_data, new_attributes_tuple) do
  #   e = get_v(old_data, index)
  #   do_change_d(size-1, index+1, old_data, put_elem(new_attributes_tuple, index, e))
  # end

  # defp get_v(old_data, index) do
  #   size = tuple_size(old_data)
  #   if index > size-1 do
  #     nil
  #   else
  #     elem(old_data, index)
  #   end
  # end

  # def do_table_name(name, tag) do
  #   String.to_atom(Atom.to_string(name) <> tag)
  # end

end
