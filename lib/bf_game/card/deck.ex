defmodule Deck do

  @doc """
  花色定义：
  1. 方块
  2. 梅花
  3. 桃花
  4. 黑桃

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

    defstruct [:suit, :rank]

  end

  def new do
    for suit <- suits(), rank <- ranks() do
      %Card{suit: suit, rank: rank}
    end |> Enum.shuffle
  end

  def zip_card(%Deck.Card{suit: suit, rank: rank}) do
    Integer.undigits([suit, rank], 16)
  end

  def unzip_card(n) do
    [suit, rank] = Integer.digits(n, 16)
    %Deck.Card{suit: suit, rank: rank}
  end

  def get_suit_pattern(cards) do
    cards
    |> Enum.sort(fn(card1, card2) -> card1.rank > card2.rank end)
    |> Enum.map(fn(card) -> card_to_tuple(card) end)
    |> do_get_suit_pattern
    |> do_tuple_to_card
  end

  def do_get_suit_pattern([{s1, a}, {s2, b}, {s3, c}, {s4, d}, {s5, e}]) when a < 5 and a + b + c + d + e <= 10 do
    {13, [{s1, a}, {s2, b}, {s3, c}, {s4, d}, {s5, e}]}
  end
  def do_get_suit_pattern([{s1, a}, {s2, b}, {s3, c}, {s4, d}, {s5, e}]) when e > 10 do
    {12, [{s1, a}, {s2, b}, {s3, c}, {s4, d}, {s5, e}]}
  end
  def do_get_suit_pattern([{s1, a}, {s2, a}, {s3, a}, {s4, a}, {s5, b}]) do
    {11, [{s1, a}, {s2, a}, {s3, a}, {s4, a}, {s5, b}]}
  end
  def do_get_suit_pattern([{s1, a}, {s2, b}, {s3, b}, {s4, b}, {s5, b}]) do
    {11, [{s1, a}, {s2, b}, {s3, b}, {s4, b}, {s5, b}]}
  end
  def do_get_suit_pattern([{s1, a1}, {s2, b1}, {s3, c1}, {s4, d1}, {s5, e1}]) do
    a = get_calculate_val(a1)
    b = get_calculate_val(b1)
    c = get_calculate_val(c1)
    d = get_calculate_val(d1)
    e = get_calculate_val(e1)
    cond do
      rem10(a, b, c) == 0 ->
        case rem10(d, e) == 0 do
          true -> {10, [{s1, a1}, {s2, b1}, {s3, c1}, {s4, d1}, {s5, e1}]}
          _ -> {rem10(d, e), [{s1, a1}, {s2, b1}, {s3, c1}, {s4, d1}, {s5, e1}]}
        end
      rem10(a, b, d) == 0 ->
        case rem10(c, e) == 0 do
          true -> {10, [{s1, a1}, {s2, b1}, {s4, d1}, {s3, c1}, {s5, e1}]}
          _ -> {rem10(c, e), [{s1, a1}, {s2, b1}, {s4, d1}, {s3, c1}, {s5, e1}]}
        end
      rem10(a, b, e) == 0 ->
        case rem10(c, d) == 0 do
          true -> {10, [{s1, a1}, {s2, b1}, {s5, e1}, {s3, c1}, {s4, d1}]}
          _ -> {rem10(c, d), [{s1, a1}, {s2, b1}, {s5, e1}, {s3, c1}, {s4, d1}]}
        end
      rem10(a, c, d) == 0 ->
        case rem10(b, e) == 0 do
          true -> {10, [{s1, a1}, {s3, c1}, {s4, d1}, {s2, b1}, {s5, e1}]}
          _ -> {rem10(b, e), [{s1, a1}, {s3, c1}, {s4, d1}, {s2, b1}, {s5, e1}]}
        end
      rem10(a, c, e) == 0 ->
        case rem10(b, d) == 0 do
          true -> {10, [{s1, a1}, {s3, c1}, {s5, e1}, {s2, b1}, {s4, d1}]}
          _ -> {rem10(b, d), [{s1, a1}, {s3, c1}, {s5, e1}, {s2, b1}, {s4, d1}]}
        end
      rem10(a, d, e) == 0 ->
        case rem10(b, c) == 0 do
          true -> {10, [{s1, a1}, {s4, d1}, {s5, e1}, {s2, b1}, {s3, c1}]}
          _ -> {rem10(b, c), [{s1, a1}, {s4, d1}, {s5, e1}, {s2, b1}, {s3, c1}]}
        end
      rem10(b, c, d) == 0 ->
        case rem10(a, e) == 0 do
          true -> {10, [{s2, b1}, {s3, c1}, {s4, d1}, {s1, a1}, {s5, e1}]}
          _ -> {rem10(a, e), [{s2, b1}, {s3, c1}, {s4, d1}, {s1, a1}, {s5, e1}]}
        end
      rem10(b, c, e) == 0 ->
        case rem10(a, d) == 0 do
          true -> {10, [{s2, b1}, {s3, c1}, {s5, e1}, {s1, a1}, {s4, d1}]}
          _ -> {rem10(a, d), [{s2, b1}, {s3, c1}, {s5, e1}, {s1, a1}, {s4, d1}]}
        end
      rem10(b, d, e) == 0 ->
        case rem10(a, c) == 0 do
          true -> {10, [{s2, b1}, {s4, d1}, {s5, e1}, {s1, a1}, {s3, c1}]}
          _ -> {rem10(a, c), [{s2, b1}, {s4, d1}, {s5, e1}, {s1, a1}, {s3, c1}]}
        end
      rem10(c, d, e) == 0 ->
        case rem10(a, b) == 0 do
          true -> {10, [{s3, c1}, {s4, d1}, {s5, e1}, {s1, a1}, {s2, b1}]}
          _ -> {rem10(a, b), [{s3, c1}, {s4, d1}, {s5, e1}, {s1, a1}, {s2, b1}]}
        end
      true -> {0, [{s1, a1}, {s2, b1}, {s3, c1}, {s4, d1}, {s5, e1}]}
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

  defp suits, do: Enum.to_list(1..4) |> Enum.shuffle

  defp ranks, do: Enum.to_list(1..13) |> Enum.shuffle
  
  defp card_to_tuple(%Deck.Card{suit: suit, rank: rank}), do: {suit, rank}

  defp tuple_to_card({suit, rank}), do: %Deck.Card{suit: suit, rank: rank}

end

