defmodule BakingSoda do
  # defmodule Object do
  #  defstruct [...]
  # end

  def load(binary) when is_binary(binary) do
    case binary do
      # TODO: What are those first three bytes?
      <<128, 4, rest::binary>> ->
        load(rest, [])

      _ ->
        {:error, "protocol version not supported"}
    end
  end

  # 46
  @stop ?.
  # 75
  @binint1 ?K
  # 134
  @tuple2 0x86
  # 135
  @tuple3 0x87
  # 140
  @short_binunicode 0x8C
  # 148
  @memoize 0x94
  # 149
  @framing 0x95
  # 71
  @binfloat ?G
  # 77
  @two_byte_int ?M
  # @empty_list 0x5D #93

  defp load(<<@binint1, int, rest::binary>>, stack) do
    load(rest, [int | stack])
  end

  defp load(<<@short_binunicode, size::little, binary::size(size)-binary, rest::binary>>, stack) do
    load(rest, [binary | stack])
  end

  defp load(<<@tuple2, rest::binary>>, [two, one | stack]) do
    load(rest, [{one, two} | stack])
  end

  defp load(<<@tuple3, rest::binary>>, [three, two, one | stack]) do
    load(rest, [{one, two, three} | stack])
  end

  defp load(<<@binfloat, value::float-big, rest::binary>>, stack) do
    load(rest, [value | stack])
  end

  defp load(<<@two_byte_int,second,first,rest::binary>>, stack) do
    <<num::integer-size(2)-unit(8)>> = <<first, second>>
    load(rest, [num | stack])
  end

  # TODO: handle memoization
  defp load(<<@memoize, rest::binary>>, stack) do
    load(rest, stack)
  end

  # TODO: handle framing
  defp load(<<@framing, _size::64, rest::binary>>, stack) do
    load(rest, stack)
  end

  defp load(<<@stop>>, [stack]) do
    {:ok, stack}
  end
end
