defmodule Deck do

  @doc """
  花色定义：
  1. 方块         1
  2. 梅花         2
  3. 桃花         3
  4. 黑桃         4

  牌型定义：
  1. 五小牛       13
  2. 五花牛       12
  3. 炸弹         11
  4. 牛牛         10
  5. 牛九          9
  6. 牛八          8
  7. 牛七          7
  8. 牛六          6
  9. 牛五          5
  10.牛四          4
  11.牛三          3
  12.牛二          2
  13.牛丁          1
  14.没牛          0
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
          true -> {10, [{a1, s1}, {b1, s2}, {d1, s4}, {c1, s3}, {e1, s5}]}
          _ -> {rem10(c, e), [{a1, s1}, {b1, s2}, {d1, s4}, {c1, s3}, {e1, s5}]}
        end
      rem10(a, b, e) == 0 ->
        case rem10(c, d) == 0 do
          true -> {10, [{a1, s1}, {b1, s2}, {e1, s5}, {c1, s3}, {d1, s4}]}
          _ -> {rem10(c, d), [{a1, s1}, {b1, s2}, {e1, s5}, {c1, s3}, {d1, s4}]}
        end
      rem10(a, c, d) == 0 ->
        case rem10(b, e) == 0 do
          true -> {10, [{a1, s1}, {c1, s3}, {d1, s4}, {b1, s2}, {e1, s5}]}
          _ -> {rem10(b, e), [{a1, s1}, {c1, s3}, {d1, s4}, {b1, s2}, {e1, s5}]}
        end
      rem10(a, c, e) == 0 ->
        case rem10(b, d) == 0 do
          true -> {10, [{a1, s1}, {c1, s3}, {e1, s5}, {b1, s2}, {d1, s4}]}
          _ -> {rem10(b, d), [{a1, s1}, {c1, s3}, {e1, s5}, {b1, s2}, {d1, s4}]}
        end
      rem10(a, d, e) == 0 ->
        case rem10(b, c) == 0 do
          true -> {10, [{a1, s1}, {d1, s4}, {e1, s5}, {b1, s2}, {c1, s3}]}
          _ -> {rem10(b, c), [{a1, s1}, {d1, s4}, {e1, s5}, {b1, s2}, {c1, s3}]}
        end
      rem10(b, c, d) == 0 ->
        case rem10(a, e) == 0 do
          true -> {10, [{b1, s2}, {c1, s3}, {d1, s4}, {a1, s1}, {e1, s5}]}
          _ -> {rem10(a, e), [{b1, s2}, {c1, s3}, {d1, s4}, {a1, s1}, {e1, s5}]}
        end
      rem10(b, c, e) == 0 ->
        case rem10(a, d) == 0 do
          true -> {10, [{b1, s2}, {c1, s3}, {e1, s5}, {a1, s1}, {d1, s4}]}
          _ -> {rem10(a, d), [{b1, s2}, {c1, s3}, {e1, s5}, {a1, s1}, {d1, s4}]}
        end
      rem10(b, d, e) == 0 ->
        case rem10(a, c) == 0 do
          true -> {10, [{b1, s2}, {d1, s4}, {e1, s5}, {a1, s1}, {c1, s3}]}
          _ -> {rem10(a, c), [{b1, s2}, {d1, s4}, {e1, s5}, {a1, s1}, {c1, s3}]}
        end
      rem10(c, d, e) == 0 ->
        case rem10(a, b) == 0 do
          true -> {10, [{c1, s3}, {d1, s4}, {e1, s5}, {a1, s1}, {b1, s2}]}
          _ -> {rem10(a, b), [{c1, s3}, {d1, s4}, {e1, s5}, {a1, s1}, {b1, s2}]}
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

