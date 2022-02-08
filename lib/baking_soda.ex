defmodule BakingSoda do
  # defmodule Object do
  #  defstruct [...]
  # end

  def load(binary) when is_binary(binary) do
    case binary do
      # TODO: What are those first three bytes?
      <<128, 4, 149, _size :: 64, rest :: binary>> ->
        load(rest, [])

      _ ->
        {:error, "protocol version not supported"}
    end
  end

  @stop ?. # 46
  @binint1 ?K # 75
  @tuple2 0x86 # 134
  @tuple3 0x87 # 135
  @short_binunicode 0x8C # 140
  @memoize 0x94 # 148
  @empty_list 0x5D #93

  defp load(<<@binint1, int, rest :: binary>>, stack) do
    load(rest, [int | stack])
  end

  defp load(<<@short_binunicode, size :: little, binary :: size(size) - binary, rest :: binary>>, stack) do
    load(rest, [binary | stack])
  end

  defp load(<<@tuple2, rest :: binary>>, [two, one | stack]) do
    load(rest, [{one, two} | stack])
  end

  defp load(<<@tuple3, rest :: binary>>, [three, two, one | stack]) do
    load(rest, [{one, two, three} | stack])
  end

  defp load(<<@end_of_list, rest :: binary>>, [three, two, one | stack]) do
    load(rest, [[one, two, three] | stack])
  end


  # TODO: handle memoization
  defp load(<<@memoize, rest :: binary>>, stack) do
    load(rest, stack)
  end

  defp load(<<@stop>>, [stack]) do
    {:ok, stack}
  end
end