defmodule Platform.HttpHandler do

  require Logger

  @doc """
  Send user token to platform, and wait response.
  """
  def post(token) do
    case post_to_platform(token) do
      %HTTPoison.Response{body: body} ->
        parse(body)
      error ->
        Logger.error "http_handler receive an error msg: #{inspect(error)}"
        :error
    end
  end

  defp post_to_platform(token) do
    token_config = Tools.get_env(:token)
    body = build_body(token, token_config)
    Logger.debug "body: #{inspect(body)}"
    HTTPoison.post token_config[:url], body
  end

  defp build_body(token, token_config) do
    rand = to_string(Enum.random(1..100))
    time = to_string(Tools.time_stamp())
    {:ok, new_token} = Base.decode64(token)
    %{
      token: new_token,
      time:  time,
      rand:  rand,
      key:   :erlang.md5(rand <> new_token <> time <> token_config[:md5sign]) |> Base.encode16(case: :lower)
    } |> URI.encode_query
  end

  def parse(string) do
    {:ok, resp} = Poison.Parser.parse(string, keys: :atoms)
    Logger.debug "parsed resp: #{inspect(resp)} "
    case resp.code == 0 do
      true ->
        {:ok, resp.data}
      _ ->
        Logger.error "http_handler receive an #{resp.code} msg: " <> resp.msg
        :error
    end
  end

end
