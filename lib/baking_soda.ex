defmodule BakingSoda do

  def load(binary) when is_binary(binary) do
    case binary do
      <<128, 4, rest::binary>> ->
        load(rest, [], [])

      _ ->
        {:error, "protocol version not supported"}
    end
  end

  # 46
  @stop ?.

  # 75
  @binint1 ?K

  # 133
  @tuple1 0x85

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

  # 147
  # (Push a global object (module.attr) on the stack)
  @stack_global 0x93

  # 40
  # (Push markobject onto the stack)
  @mark ?(

  # 67
  # There are two arguments:  the first is a 1-byte unsigned int giving
  # the number of bytes, and the second is that many bytes, which are taken
  # literally as the string content.
  @short_binbytes ?C

  # 137
  # new false
  @new_false 0x89

  # 136
  # new true
  @new_true 0x88

  # 78
  # new None
  @new_none ?N

  # 74
  # four byte signed integer
  @four_byte_int ?J

  # 116
  # All the stack entries following the topmost markobject are placed into
  # a single Python tuple, which single tuple object replaces all of the
  # stack from the topmost markobject onward.  For example,
  # Stack before: ... markobject 1 2 3 'abc'
  # Stack after:  ... (1, 2, 3, 'abc')
  @tuple ?t

  # 82
  @reduce ?R

  # 104
  # Read an object from the memo and push it on the stack.
  # The index of the memo object to push is given by the 1-byte unsigned
  # integer following.
  @bin_get ?h

  # 98
  # Finish building an object, via __setstate__ or dict update.
  #     Stack before: ... anyobject argument
  #     Stack after:  ... anyobject
  #     where anyobject may have been mutated, as follows:
  #     If the object has a __setstate__ method,
  #         anyobject.__setstate__(argument)
  #     is called.
  #     Else the argument must be a dict, the object must have a __dict__, and
  #     the object is updated via
  #         anyobject.__dict__.update(argument)
  @build ?b

  # 41
  # Push an empty tuple
  @empty_tuple ?)

  # 93
  # Push an empty list
  @empty_list ?]

  # 101
  # append everyithing to list before :mark
  @appends ?e

  # 97
  # append one element
  @append ?a

  # 129
  # build a new object and push on a stack
  @new_object 0x81

  # 125
  # push an empty dict on a stack
  @empty_dict ?}


  # 143
  # push an empty set on a stack
  @empty_set 0x8F

  # 66
  # Push a Python bytes object.
  # There are two arguments:  the first is a 4-byte little-endian unsigned int
  # giving the number of bytes, and the second is that many bytes, which are
  # taken literally as the bytes content.
  @binbytes ?B

  # 117
  # Add an arbitrary number of key+value pairs to an existing dict.
  # The slice of the stack following the topmost markobject is taken as
  # an alternating sequence of keys and values, added to the dict
  # immediately under the topmost markobject.  Everything at and after the
  # topmost markobject is popped, leaving the mutated dict at the top
  # of the stack.
  # Stack before:  ... pydict markobject key_1 value_1 ... key_n value_n
  # Stack after:   ... pydict
  # where pydict has been modified via pydict[key_i] = value_i for i in
  # 1, 2, ..., n, and in that order.
  @set_items ?u

  # 106
  # Read an object from the memo and push it on the stack.
  # The index of the memo object to push is given by the 4-byte unsigned
  # little-endian integer following.
  @long_bin_get ?j

  # 115
  # Add a key+value pair to an existing dict.
  # Stack before:  ... pydict key value
  # Stack after:   ... pydict
  # where pydict has been modified via pydict[key] = value.
  @set_item ?s

  defp load(<<@binint1, int, rest::binary>>, stack, memo) do
    load(rest, [int | stack], memo)
  end

  defp load(
         <<@short_binunicode, size::little, binary::size(size)-binary, rest::binary>>,
         stack,
         memo
       ) do
    load(rest, [binary | stack], memo)
  end

  defp load(
         <<@short_binbytes, size::little, binary::size(size)-binary, rest::binary>>,
         stack,
         memo
       ) do
    load(rest, [binary | stack], memo)
  end

  defp load(<<@tuple1, rest::binary>>, [one | stack], memo) do
    load(rest, [{one} | stack], memo)
  end

  defp load(<<@tuple2, rest::binary>>, [two, one | stack], memo) do
    load(rest, [{one, two} | stack], memo)
  end

  defp load(<<@tuple3, rest::binary>>, [three, two, one | stack], memo) do
    load(rest, [{one, two, three} | stack], memo)
  end

  defp load(<<@binfloat, value::float-big, rest::binary>>, stack, memo) do
    load(rest, [value | stack], memo)
  end

  defp load(<<@four_byte_int, value::32-integer-big-signed, rest::binary>>, stack, memo) do
    load(rest, [value | stack], memo)
  end

  defp load(<<@two_byte_int, second, first, rest::binary>>, stack, memo) do
    <<num::integer-size(2)-unit(8)>> = <<first, second>>
    load(rest, [num | stack], memo)
  end

  defp load(<<@memoize, rest::binary>>, [top | _] = stack, memo) do
    load(rest, stack, [top | memo])
  end

  defp load(<<@mark, rest::binary>>, stack, memo) do
    load(rest, [:mark | stack], memo)
  end

  # TODO: handle framing
  defp load(<<@framing, _size::64, rest::binary>>, stack, memo) do
    load(rest, stack, memo)
  end

  defp load(<<@stack_global, rest::binary>>, [two, one | stack], memo) do
    load(rest, [{:qualifier, one, two} | stack], memo)
  end

  defp load(<<@reduce, rest::binary>>, [arg, class | stack], memo) do
    case class do
      {:qualifier, "collections", "OrderedDict"} -> load(rest, [%{} | stack], memo)
      _ -> load(rest, [{:reduce, class, arg} | stack], memo)
    end
  end

  defp load(<<@bin_get, idx::little, rest::binary>>, stack, memo) do
    n = length(memo)
    el = Enum.at(memo, n - 1 - idx)
    load(rest, [el | stack], memo)
  end

  defp load(<<@long_bin_get, idx::32-integer-little-unsigned, rest::binary>>, stack, memo) do
    n = length(memo)
    el = Enum.at(memo, n - 1 - idx)
    load(rest, [el | stack], memo)
  end

  defp load(<<@new_false, rest::binary>>, stack, memo) do
    load(rest, [false | stack], memo)
  end

  defp load(<<@new_true, rest::binary>>, stack, memo) do
    load(rest, [true | stack], memo)
  end

  defp load(<<@new_none, rest::binary>>, stack, memo) do
    load(rest, [nil | stack], memo)
  end

  defp load(<<@tuple, rest::binary>>, stack, memo) do
    {leading, [:mark | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    tuple = List.to_tuple(leading)
    load(rest, [tuple | rest_stack], memo)
  end

  defp load(<<@appends, rest::binary>>, stack, memo) do
    {leading, [:mark, list_ | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    load(rest, [Enum.reverse(leading) ++ list_ | rest_stack], memo)
  end

  defp load(<<@append, rest::binary>>, [el, list_ | stack], memo) do
    load(rest, [[el | list_] | stack], memo)
  end

  defp load(<<@build, rest::binary>>, [arg, object | stack], memo) do
    load(rest, [{:build, object, arg} | stack], memo)
  end

  defp load(<<@empty_tuple, rest::binary>>, stack, memo) do
    load(rest, [{} | stack], memo)
  end

  defp load(<<@empty_list, rest::binary>>, stack, memo) do
    load(rest, [[] | stack], memo)
  end

  defp load(<<@new_object, rest::binary>>, [cls, args | stack], memo) do
    load(rest, [{:new_object, cls, args} | stack], memo)
  end

  defp load(<<@empty_dict, rest::binary>>, stack, memo) do
    load(rest, [%{} | stack], memo)
  end

  defp load(<<@empty_set, rest::binary>>, stack, memo) do
    load(rest, [MapSet.new() | stack], memo)
  end

  defp load(
         <<@binbytes, value::32-integer-little-unsigned, binary::size(value)-binary,
           rest::binary>>,
         stack,
         memo
       ) do
    load(rest, [binary | stack], memo)
  end

  defp load(<<@set_items, rest::binary>>, stack, memo) do
    {leading, [:mark, dict_ | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    chunked_leading = Enum.chunk_every(leading, 2)
    new_dict = for [val, key] <- chunked_leading, into: %{}, do: {key, val}
    final_dict = Map.merge(new_dict, dict_)
    load(rest, [final_dict | rest_stack], memo)
  end

  defp load(<<@set_item, rest::binary>>, [value, key, dict_| stack], memo) do
      new_dict = Map.put(dict_, key, value)
      load(rest, [new_dict | stack], memo)
  end

  defp load(<<@stop>>, [stack], _) do
    {:ok, stack}
  end
end
