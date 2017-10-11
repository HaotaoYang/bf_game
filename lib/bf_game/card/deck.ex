defmodule Deck do

  @doc """
  花色定义：
  1. 方块         1
  2. 梅花         2
  3. 桃花         3
  4. 黑桃         4

  牌型定义：
  1. 五小牛       13      6倍
  2. 五花牛       12      5倍
  3. 炸弹         11      4倍
  4. 牛牛         10      3倍
  5. 牛九          9      2倍
  6. 牛八          8      2倍
  7. 牛七          7      2倍
  8. 牛六          6      1倍
  9. 牛五          5      1倍
  10.牛四          4      1倍
  11.牛三          3      1倍
  12.牛二          2      1倍
  13.牛丁          1      1倍
  14.没牛          0      1倍
  """

  defmodule Card do

    defstruct [:rank, :suit]

  end

  def new do
    for rank <- ranks(), suit <- suits() do
      %Card{rank: rank, suit: suit}
    end |> Enum.shuffle
  end

  def pack_card(%Deck.Card{rank: rank, suit: suit}) do
    Integer.undigits([suit, rank], 16)
  end

  def unpack_card(n) do
    [suit, rank] = Integer.digits(n, 16)
    %Deck.Card{rank: rank, suit: suit}
  end

  @doc """
  根据牌型获取庄家赢的倍数
  """
  def get_dealer_multiple(13), do: 6
  def get_dealer_multiple(12), do: 5
  def get_dealer_multiple(11), do: 4
  def get_dealer_multiple(10), do: 3
  def get_dealer_multiple(9), do: 2
  def get_dealer_multiple(8), do: 2
  def get_dealer_multiple(7), do: 2
  def get_dealer_multiple(_), do: 1

  @doc """
  根据牌型获取玩家赢的倍数
  """
  def get_user_multiple(13), do: 5.7
  def get_user_multiple(12), do: 4.75
  def get_user_multiple(11), do: 3.8
  def get_user_multiple(10), do: 2.85
  def get_user_multiple(9), do: 1.9
  def get_user_multiple(8), do: 1.9
  def get_user_multiple(7), do: 1.9
  def get_user_multiple(_), do: 0.95

  def get_suit_pattern(cards) do
    cards
    |> Enum.map(fn(card) -> card_to_tuple(card) end)
    |> Enum.sort()
    |> Enum.reverse()
    |> do_get_suit_pattern
    |> do_tuple_to_card
  end

  def do_get_suit_pattern([{a, s1}, {b, s2}, {c, s3}, {d, s4}, {e, s5}]) when a < 5 and a + b + c + d + e <= 10 do
    {13, [{a, s1}, {b, s2}, {c, s3}, {d, s4}, {e, s5}]}
  end
  def do_get_suit_pattern([{a, s1}, {b, s2}, {c, s3}, {d, s4}, {e, s5}]) when e > 10 do
    {12, [{a, s1}, {b, s2}, {c, s3}, {d, s4}, {e, s5}]}
  end
  def do_get_suit_pattern([{a, s1}, {a, s2}, {a, s3}, {a, s4}, {b, s5}]) do
    {11, [{a, s1}, {a, s2}, {a, s3}, {a, s4}, {b, s5}]}
  end
  def do_get_suit_pattern([{a, s1}, {b, s2}, {b, s3}, {b, s4}, {b, s5}]) do
    {11, [{a, s1}, {b, s2}, {b, s3}, {b, s4}, {b, s5}]}
  end
  def do_get_suit_pattern([{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]) do
    a = get_calculate_val(a1)
    b = get_calculate_val(b1)
    c = get_calculate_val(c1)
    d = get_calculate_val(d1)
    e = get_calculate_val(e1)
    cond do
      rem10(a, b, c) == 0 ->
        case rem10(d, e) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(d, e), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(a, b, d) == 0 ->
        case rem10(c, e) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(c, e), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(a, b, e) == 0 ->
        case rem10(c, d) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(c, d), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(a, c, d) == 0 ->
        case rem10(b, e) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(b, e), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(a, c, e) == 0 ->
        case rem10(b, d) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(b, d), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(a, d, e) == 0 ->
        case rem10(b, c) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(b, c), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(b, c, d) == 0 ->
        case rem10(a, e) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(a, e), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(b, c, e) == 0 ->
        case rem10(a, d) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(a, d), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(b, d, e) == 0 ->
        case rem10(a, c) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(a, c), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      rem10(c, d, e) == 0 ->
        case rem10(a, b) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
          _ -> {rem10(a, b), [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
        end
      true -> {0, [{a1, s1}, {b1, s2}, {c1, s3}, {d1, s4}, {e1, s5}]}
    end
  end
  def do_get_suit_pattern(cards) do
    {0, cards}
  end

  def do_tuple_to_card({ranking, cards}) do
    ret = Enum.map(cards, fn(card) -> tuple_to_card(card) end)
    {ranking, ret}
  end

  defp get_calculate_val(val) do
    case val > 10 do
      true -> 10
      _ -> val
    end
  end

  defp rem10(a, b) do
    rem(a + b, 10)
  end

  defp rem10(a, b, c) do
    rem(a + b + c, 10)
  end

  defp ranks, do: Enum.to_list(1..13) |> Enum.shuffle

  defp suits, do: Enum.to_list(1..4) |> Enum.shuffle

  defp card_to_tuple(%Deck.Card{rank: rank, suit: suit}), do: {rank, suit}

  defp tuple_to_card({rank, suit}), do: %Deck.Card{rank: rank, suit: suit}

end

