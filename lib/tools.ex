defmodule Tools do

  require Logger
  alias BfGame.Endpoint

  ## 时间戳(秒)
  def time_stamp() do
    :erlang.system_time(:second)
  end

  ## 时间戳(毫秒)
  def millisecond() do
    :erlang.system_time(:millisecond)
  end

  ## 时间戳(微秒)
  def microsecond() do
    :erlang.system_time(:microsecond)
  end

  ## 生成随机种子
  def gen_random_seed() do
    :rand.seed(:exs1024, :erlang.timestamp())
  end

  def get_env(:start) do
    Mix.env()
  end
  def get_env(type) do
    case Application.get_env(:bf_game, type) do
      nil ->
        Logger.error("undefined env, type = #{inspect(type)}")
        nil
      other ->
        other
    end
  end

  ## 根据玩家id生成secret
  def gen_secret(user_id) do
    Phoenix.Token.sign(Endpoint, "???", :erlang.term_to_binary(user_id))
  end

  ## 重连时secret验证
  def verify_secret(secret) do
    case Phoenix.Token.verify(Endpoint, "???", secret) do
      {:ok, binary} ->
        {:ok, :erlang.binary_to_term(binary)}
      _ ->
        {:error, "token invalid"}
    end
  end

end
