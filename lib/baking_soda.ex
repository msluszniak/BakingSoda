defmodule BakingSoda do

  def load(binary) when is_binary(binary) do
    builders = %{
      {:reduce, {:qualifier_stack_global, "numpy", "dtype"}, {"i8", false, true}} => fn _, _, _ ->
        {:u, 64}
      end,
      {:reduce, {:qualifier_stack_global, "numpy", "dtype"}, {"f8", false, true}} => fn _, _, _ ->
        {:f, 64}
      end,
      {:reduce, {:qualifier_stack_global, "numpy", "dtype"}, {"i4", false, true}} => fn _, _, _ ->
        {:u, 32}
      end,
      {:reduce, {:qualifier_stack_global, "numpy", "dtype"}, {"f4", false, true}} => fn _, _, _ ->
        {:f, 32}
      end,
      {:reduce, {:qualifier_stack_global, "numpy.core.multiarray", "_reconstruct"},
       {{:qualifier_stack_global, "numpy", "ndarray"}, {0}, "b"}} => fn _, [arg, _ | _], _ ->
        {_, shape, type, _, content} = arg
        Nx.from_binary(content, type) |> Nx.reshape(shape)
      end
    }

    case binary do
      <<128, 4, rest::binary>> ->
        load(rest, [], [], builders)

      <<128, 2, rest::binary>> ->
        load(rest, [], [], builders)

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
  # append everything to list before :mark
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

  # 108
  # Build a list out of the topmost stack slice, after markobject.
  # All the stack entries following the topmost markobject are placed into
  # a single Python list, which single list object replaces all of the
  # stack from the topmost markobject onward.  For example,
  # Stack before: ... markobject 1 2 3 'abc'
  # Stack after:  ... [1, 2, 3, 'abc']
  @list ?l

  # 138
  # long with 1 byte size and rest in little endian
  @long1 0x8A

  # 113
  # Store the stack top into the memo.  The stack is not popped.
  # The index of the memo location to write into is given by the 1-byte
  # unsigned integer following.
  @bin_put ?q

  # 88
  # Push a Python Unicode string object.
  # There are two arguments:  the first is a 4-byte little-endian unsigned int
  # giving the number of bytes in the string.  The second is that many
  # bytes, and is the UTF-8 encoding of the Unicode string.
  @bin_unicode ?X

  # 99
  # Push a global object (module.attr) on the stack.
  # Two newline-terminated strings follow the GLOBAL opcode.  The first is
  # taken as a module name, and the second as a class name.  The class
  # object module.class is pushed on the stack.  More accurately, the
  # object returned by self.find_class(module, class) is pushed on the
  # stack, so unpickling subclasses can override this form of lookup.
  @global ?c

  # 81
  # Push an object identified by a persistent ID.
  # Like PERSID, except the persistent ID is popped off the stack (instead
  # of being a string embedded in the opcode bytestream).  The persistent
  # ID is passed to self.persistent_load(), and whatever object that
  # returns is pushed on the stack.  See PERSID for more detail.
  @bin_pers_id ?Q



  defp load(<<@binint1, int, rest::binary>>, stack, memo, builders) do
    load(rest, [int | stack], memo, builders)
  end

  defp load(
         <<@short_binunicode, size::little, binary::size(size)-binary, rest::binary>>,
         stack,
         memo,
         builders
       ) do
    load(rest, [binary | stack], memo, builders)
  end

  defp load(
         <<@short_binbytes, size::little, binary::size(size)-binary, rest::binary>>,
         stack,
         memo,
         builders
       ) do
    load(rest, [binary | stack], memo, builders)
  end

  defp load(<<@tuple1, rest::binary>>, [one | stack], memo, builders) do
    load(rest, [{one} | stack], memo, builders)
  end

  defp load(<<@tuple2, rest::binary>>, [two, one | stack], memo, builders) do
    load(rest, [{one, two} | stack], memo, builders)
  end

  defp load(<<@tuple3, rest::binary>>, [three, two, one | stack], memo, builders) do
    load(rest, [{one, two, three} | stack], memo, builders)
  end

  defp load(<<@binfloat, value::float-big, rest::binary>>, stack, memo, builders) do
    load(rest, [value | stack], memo, builders)
  end

  defp load(<<@four_byte_int, value::32-integer-big-signed, rest::binary>>, stack, memo, builders) do
    load(rest, [value | stack], memo, builders)
  end

  defp load(<<@two_byte_int, second, first, rest::binary>>, stack, memo, builders) do
    <<num::integer-size(2)-unit(8)>> = <<first, second>>
    load(rest, [num | stack], memo, builders)
  end

  defp load(
         <<@long1, size, value::size(size)-unit(8)-integer-little-signed, rest::binary>>,
         stack,
         memo,
         builders
       ) do
    load(rest, [value | stack], memo, builders)
  end

  defp load(<<@memoize, rest::binary>>, [top | _] = stack, memo, builders) do
    load(rest, stack, [top | memo], builders)
  end

  defp load(<<@mark, rest::binary>>, stack, memo, builders) do
    load(rest, [:mark | stack], memo, builders)
  end

  defp load(<<@framing, _size::64, rest::binary>>, stack, memo, builders) do
    load(rest, stack, memo, builders)
  end

  defp load(<<@stack_global, rest::binary>>, [two, one | stack], memo, builders) do
    load(rest, [{:qualifier_stack_global, one, two} | stack], memo, builders)
  end

  # in current version I skip the newlines (<<10>>)
  def parse_global(binary) do
    parse_global(binary, <<>>)
  end

  def parse_global(<<byte::binary-size(1)-unit(8), rest::binary>>, word1) do
    case byte do
      <<10>> -> parse_global(rest, word1, <<>>)
      _ -> parse_global(rest, word1 <> byte)
    end
  end

  def parse_global(<<byte::binary-size(1)-unit(8), rest::binary>>, word1, word2) do
    case byte do
      <<10>> -> {word1, word2, rest}
      _ -> parse_global(rest, word1, word2 <> byte)
    end
  end

  defp load(<<@global, rest::binary>>, stack, memo, builders) do
    {module, class, rest} = parse_global(rest)
    load(rest, [{:qualifier_global, module, class} | stack], memo, builders)
  end

  defp load(<<@reduce, rest::binary>>, [arg, class | stack], memo, builders) do
    case class do
      {:qualifier_stack_global, "collections", "OrderedDict"} ->
        load(rest, [%{} | stack], memo, builders)

      {:qualifier_stack_global, "torch.storage", "_load_from_bytes"} ->
        # File.write!("torch_storage.b", arg, [:binary])
        {arg_new} = arg
        File.write!("torch_storage.b", arg_new)
        # File.write!("torch_storage.b", inspect(arg_new, limit: :infinity))
        load(rest, [{:reduce, class, arg} | stack], memo, builders)

      _ ->
        load(rest, [{:reduce, class, arg} | stack], memo, builders)
    end
  end

  defp load(<<@bin_get, idx::little, rest::binary>>, stack, memo, builders) do
    n = length(memo)
    el = Enum.at(memo, n - 1 - idx)
    load(rest, [el | stack], memo, builders)
  end

  defp load(
         <<@long_bin_get, idx::32-integer-little-unsigned, rest::binary>>,
         stack,
         memo,
         builders
       ) do
    n = length(memo)
    el = Enum.at(memo, n - 1 - idx)
    load(rest, [el | stack], memo, builders)
  end

  # there should be utf-8 instead binary, but I cannot set the length of a unicode string.
  defp load(
         <<@bin_unicode, size::32-integer-little-unsigned, value::size(size)-binary,
           rest::binary>>,
         stack,
         memo,
         builders
       ) do
    load(rest, [value | stack], memo, builders)
  end

  defp load(<<@new_false, rest::binary>>, stack, memo, builders) do
    load(rest, [false | stack], memo, builders)
  end

  defp load(<<@new_true, rest::binary>>, stack, memo, builders) do
    load(rest, [true | stack], memo, builders)
  end

  defp load(<<@new_none, rest::binary>>, stack, memo, builders) do
    load(rest, [nil | stack], memo, builders)
  end

  defp load(<<@tuple, rest::binary>>, stack, memo, builders) do
    {leading, [:mark | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    leading = Enum.reverse(leading)
    tuple = List.to_tuple(leading)
    load(rest, [tuple | rest_stack], memo, builders)
  end

  defp load(<<@appends, rest::binary>>, stack, memo, builders) do
    {leading, [:mark, list_ | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    load(rest, [Enum.reverse(leading) ++ list_ | rest_stack], memo, builders)
  end

  defp load(<<@list, rest::binary>>, stack, memo, builders) do
    {leading, [:mark | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    load(rest, [Enum.reverse(leading) | rest_stack], memo, builders)
  end

  defp load(<<@append, rest::binary>>, [el, list_ | stack], memo, builders) do
    load(rest, [[el | list_] | stack], memo, builders)
  end

  defp load(<<@build, rest::binary>>, [arg, object | stack], memo, builders) do
    case Map.has_key?(builders, object) do
      true ->
        val = Map.fetch!(builders, object)
        load(rest, [val.(rest, [arg, object | stack], memo) | stack], memo, builders)

      false ->
        load(rest, [{:build, object, arg} | stack], memo, builders)
    end
  end

  defp load(<<@empty_tuple, rest::binary>>, stack, memo, builders) do
    load(rest, [{} | stack], memo, builders)
  end

  defp load(<<@empty_list, rest::binary>>, stack, memo, builders) do
    load(rest, [[] | stack], memo, builders)
  end

  defp load(<<@new_object, rest::binary>>, [cls, args | stack], memo, builders) do
    load(rest, [{:new_object, cls, args} | stack], memo, builders)
  end

  defp load(<<@empty_dict, rest::binary>>, stack, memo, builders) do
    load(rest, [%{} | stack], memo, builders)
  end

  defp load(<<@empty_set, rest::binary>>, stack, memo, builders) do
    load(rest, [MapSet.new() | stack], memo, builders)
  end

  defp load(
         <<@binbytes, value::32-integer-little-unsigned, binary::size(value)-binary,
           rest::binary>>,
         stack,
         memo,
         builders
       ) do
    load(rest, [binary | stack], memo, builders)
  end

  defp load(<<@set_items, rest::binary>>, stack, memo, builders) do
    {leading, [:mark, dict_ | rest_stack]} = Enum.split_while(stack, &(&1 != :mark))
    chunked_leading = Enum.chunk_every(leading, 2)
    new_dict = for [val, key] <- chunked_leading, into: %{}, do: {key, val}
    final_dict = Map.merge(new_dict, dict_)
    load(rest, [final_dict | rest_stack], memo, builders)
  end

  defp load(<<@set_item, rest::binary>>, [value, key, dict_ | stack], memo, builders) do
    new_dict = Map.put(dict_, key, value)
    load(rest, [new_dict | stack], memo, builders)
  end

  # TODO: test this one
  defp load(<<@bin_put, idx, rest::binary>>, [top | stack], memo, builders) do
    n = length(memo)

    new_memo =
      case n do
        0 -> [top]
        _ -> List.update_at(memo, n - idx - 1, fn _ -> top end)
      end

    load(rest, [top | stack], new_memo, builders)
  end

  defp load(<<@bin_pers_id, rest::binary>>, stack, memo, builders) do
    load(rest, stack, memo, builders)
  end

  defp load(<<@stop, rest::binary>>, [stack], _, _) do
    {:ok, stack, rest}
  end
end
