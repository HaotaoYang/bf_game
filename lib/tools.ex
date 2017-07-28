defmodule Tools do

  def time_stamp() do
    {m, s, _} = :erlang.timestamp()
    m * 1000000 + s
  end

  def millisecond() do
    {m, s, ms} = :erlang.timestamp()
    m * 1000000000 + s * 1000 + div(ms, 1000)
  end

  def seed_random_number_generator() do
    :rand.seed(exs1024, :erlang.timestamp()),
  end

end
