defmodule FileLogger do
  @moduledoc """
  文件日志
  """
  
  defstruct [
    format: nil,
    metadata: nil,
    level: nil,
    device: nil,
    max_buffer: nil,
    buffer_size: 0,
    buffer: [],
    ref: nil,
    output: nil,
    path: nil,
    rotate: nil,
    start_time: nil,
    rotate_timer: nil
  ]

  ## =================================================================
  ## callback
  ## =================================================================
  def init(__MODULE__) do
    config = Application.get_env(:logger, __MODULE__)
    {:ok, init(config, %__MODULE__{})}
  end

  def init({__MODULE__, opts}) when is_list(opts) do
    config = configure_merge(Application.get_env(:logger, __MODULE__), opts)
    {:ok, init(config, %__MODULE__{})}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end
  def handle_event({level, _gl, {Logger, msg, ts, md}}, state) do
    %{level: log_level, ref: ref, buffer_size: buffer_size, max_buffer: max_buffer} = state
    cond do
      not meet_level?(level, log_level) ->
        {:ok, state}
      is_nil(ref) ->
        {:ok, log_event(level, msg, ts, md, state)}
      buffer_size < max_buffer ->
        {:ok, buffer_event(level, msg, ts, md, state)}
      buffer_size === max_buffer ->
        state = buffer_event(level, msg, ts, md, state)
        {:ok, await_io(state)}
    end
  end
  def handle_event(:flush, state) do
    {:ok, flush(state)}
  end
  def handle_event(_, state) do
    {:ok, state}
  end

  def handle_info({:io_reply, ref, msg}, %{ref: ref} = state) do
    {:ok, handle_io_reply(msg, state)}
  end
  def handle_info({:DOWN, ref, _, pid, reason}, %{ref: ref}) do
    raise "device #{inspect pid} exited: " <> Exception.format_exit(reason)
  end
  def handle_info(:rotate, state) do
    rotate_timer = reset_timer(state.rotate_timer, state.start_time, state.rotate)
    with {:ok, 0} <- :file.position(state.device, {:cur, 0}) do
        {:ok, %{state | rotate_timer: rotate_timer}}
    else
      _ ->
        today = Date.to_iso8601(Date.utc_today(), :basic)
        {:ok, device} = File.open(:filename.join([state.path, "log_#{today}.log"]), [:append])
        :ok = File.close(state.device)
        {:ok, %{state | rotate_timer: rotate_timer, device: device}}
    end
  end
  def handle_info(_, state) do
    {:ok, state}
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  ## =================================================================
  ## private
  ## =================================================================
  defp init(config, state) do
    level = Keyword.get(config, :level)
    path = Keyword.get(config, :path, "var/log")
    :ok = File.mkdir_p(path)
    today = Date.to_iso8601(Date.utc_today(), :basic)
    {:ok, device} = File.open(:filename.join([path, "log_#{today}.log"]), [:append])
    format = Logger.Formatter.compile Keyword.get(config, :format)
    metadata = Keyword.get(config, :metadata, []) |> configure_metadata()
    max_buffer = Keyword.get(config, :max_buffer, 32)
    rotate = case Keyword.get(config, :rotate, 1) do
      r when is_integer(r) -> max(1, r)
      _ -> 1
    end
    start_time = :calendar.local_time()
    rotate_timer = reset_timer(state.rotate_timer, start_time, rotate)
    %{state | format: format, metadata: metadata, level: level, device: device, max_buffer: max_buffer, path: path, rotate: rotate, start_time: start_time, rotate_timer: rotate_timer}
  end

  defp configure(options, state) do
    config = configure_merge(Application.get_env(:logger, __MODULE__), options)
    Application.put_env(:logger, __MODULE__, config)
    init(config, state)
  end

  defp configure_merge(env, options) do
    Keyword.merge(env, options, fn(_, _v1, v2) -> v2 end)
  end

  defp meet_level?(_lvl, nil), do: true
  defp meet_level?(lvl, min) do
    Logger.compare_levels(lvl, min) != :lt
  end

  defp configure_metadata(:all), do: :all
  defp configure_metadata(metadata), do: Enum.reverse(metadata)

  defp log_event(level, msg, ts, md, %{device: device} = state) do
    output = format_event(level, msg, ts, md, state)
    %{state | ref: async_io(device, output), output: output}
  end

  defp buffer_event(level, msg, ts, md, state) do
    %{buffer: buffer, buffer_size: buffer_size} = state
    buffer = [buffer | format_event(level, msg, ts, md, state)]
    %{state | buffer: buffer, buffer_size: buffer_size + 1}
  end

  defp async_io(name, output) when is_atom(name) do
    case Process.whereis(name) do
      device when is_pid(device) ->
        async_io(device, output)
      nil ->
        raise "no device registered with the name #{inspect name}"
    end
  end

  defp async_io(device, output) when is_pid(device) do
    ref = Process.monitor(device)
    send(device, {:io_request, self(), ref, {:put_chars, :unicode, output}})
    ref
  end

  defp await_io(%{ref: nil} = state), do: state
  defp await_io(%{ref: ref} = state) do
    receive do
      {:io_reply, ^ref, :ok} ->
        handle_io_reply(:ok, state)
      {:io_reply, ^ref, error} ->
        handle_io_reply(error, state)
        |> await_io()
      {:DOWN, ^ref, _, pid, reason} ->
        raise "device #{inspect pid} exited: " <> Exception.format_exit(reason)
    end
  end

  defp format_event(level, msg, ts, md, state) do
    %{format: format, metadata: keys} = state
    format
    |> Logger.Formatter.format(level, msg, ts, take_metadata(md, keys))
  end

  defp take_metadata(metadata, :all), do: metadata
  defp take_metadata(metadata, keys) do
    Enum.reduce keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error     -> acc
      end
    end
  end

  defp log_buffer(%{buffer_size: 0, buffer: []} = state), do: state
  defp log_buffer(state) do
    %{device: device, buffer: buffer} = state
    %{state | ref: async_io(device, buffer), buffer: [], buffer_size: 0,
      output: buffer}
  end

  defp handle_io_reply(:ok, %{ref: ref} = state) do
    Process.demonitor(ref, [:flush])
    log_buffer(%{state | ref: nil, output: nil})
  end
  defp handle_io_reply({:error, {:put_chars, :unicode, _} = error}, state) do
    retry_log(error, state)
  end
  defp handle_io_reply({:error, :put_chars}, %{output: output} = state) do
    retry_log({:put_chars, :unicode, output}, state)
  end
  defp handle_io_reply({:error, error}, _) do
    raise "failure while logging console messages: " <> inspect(error)
  end

  defp retry_log(error, %{device: device, ref: ref, output: dirty} = state) do
    Process.demonitor(ref, [:flush])
    case :unicode.characters_to_binary(dirty) do
      {_, good, bad} ->
        clean = [good | Logger.Formatter.prune(bad)]
        %{state | ref: async_io(device, clean), output: clean}
      _ ->
        # A well behaved IO device should not error on good data
        raise "failure while logging consoles messages: " <> inspect(error)
    end
  end

  defp flush(%{ref: nil} = state), do: state
  defp flush(state) do
    state
    |> await_io()
    |> flush()
  end

  defp reset_timer(ref, {date, _}, rotate) do
    if is_reference ref do
      Process.cancel_timer(ref)
    end
    {now_date, time} = :calendar.local_time()
    days = max(0, :calendar.date_to_gregorian_days(now_date) - :calendar.date_to_gregorian_days(date))
    set_time = if days >= rotate do
      rotate * 86400 - :calendar.time_to_seconds(time) + 60
    else
      (rotate - days) * 86400 - :calendar.time_to_seconds(time) + 60
    end
    Process.send_after(self(), :rotate, set_time * 1000)
  end

end
