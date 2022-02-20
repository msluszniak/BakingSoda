defmodule BakingSodaTest do
  use ExUnit.Case
  doctest BakingSoda


  # binary representation of 6 (one byte int)
  @one_byte_int <<128, 4, 75, 6, 46>>
  test "one_byte_int" do
    assert {:ok, 6} = BakingSoda.load(@one_byte_int)
  end

  # binary representation of 7312
  @two_byte_int <<128, 4, 149, 4, 0, 0, 0, 0, 0, 0, 0, 77, 144, 28, 46>>
  test "two_byte_int" do
    assert {:ok, 7312} = BakingSoda.load(@two_byte_int)
  end

  # binary representation of tuple (1,2)
  @tuple2 <<128, 4, 149, 7, 0, 0, 0, 0, 0, 0, 0, 75, 1, 75, 2, 134, 148, 46>>
  test "tuple" do
    assert {:ok, {1,2}} = BakingSoda.load(@tuple2)
  end

  # binary representation of tuple (1,2,3)
  @tuple3 <<128, 4, 149, 9, 0, 0, 0, 0, 0, 0, 0, 75, 1, 75, 2, 75, 3, 135, 148, 46>>
  test "tuple3" do
    assert {:ok, {1,2,3}} = BakingSoda.load(@tuple3)
  end

  # binary representation of nested tuple (1, 2, (3, 4))
  @nested_tuple <<128, 4, 149, 13, 0, 0, 0, 0, 0, 0, 0, 75, 1, 75, 2, 75, 3, 75, 4, 134, 148,
  135, 148, 46>>
  test "nested_tuple" do
    assert {:ok, {1,2,{3,4}}} = BakingSoda.load(@nested_tuple)
  end

  # binary representation of double 1.0
  @float <<128, 4, 149, 10, 0, 0, 0, 0, 0, 0, 0, 71, 63, 240, 0, 0, 0, 0, 0, 0, 46>>
  test "float" do
    assert {:ok, 1.0} = BakingSoda.load(@float)
  end

  # binary representation of string
  @string <<128, 4, 149, 10, 0, 0, 0, 0, 0, 0, 0, 140, 6, 115, 116, 114, 105, 110, 103,
  148, 46>>
  test "string" do
    assert {:ok, "string"} = BakingSoda.load(@string)
  end

  #binary representation of {"a" : 1}
  @dict_with_one_pair <<128, 4, 149, 10, 0, 0, 0, 0, 0, 0, 0, 125, 148, 140, 1, 97, 148, 75, 1, 115,
  46>>
  test "dict_with_one_pair" do
    assert {:ok, %{"a" => 1}} = BakingSoda.load(@dict_with_one_pair)
  end

  #binary representation of {"a":1, "b":2, "c":3}
  @dict <<128, 4, 149, 23, 0, 0, 0, 0, 0, 0, 0, 125, 148, 40, 140, 1, 97, 148, 75, 1,
  140, 1, 98, 148, 75, 2, 140, 1, 99, 148, 75, 3, 117, 46>>
  test "dict" do
    assert {:ok, %{"a" => 1, "b" => 2, "c" => 3}} = BakingSoda.load(@dict)
  end

  #binary representation of [1,2,3,"a"]
  @list <<128, 4, 149, 15, 0, 0, 0, 0, 0, 0, 0, 93, 148, 40, 75, 1, 75, 2, 75, 3, 140,
  1, 97, 148, 101, 46>>
  test "list" do
    assert {:ok, [1,2,3,"a"]} = BakingSoda.load(@list)
  end

  #binary representation of [1]
  @list_one <<128, 4, 149, 6, 0, 0, 0, 0, 0, 0, 0, 93, 148, 75, 1, 97, 46>>
  test "list_one" do
    assert {:ok, [1]} = BakingSoda.load(@list_one)
  end

  #binary representation of [1,2,[3, 4,[5]]]
  @nested_list <<128, 4, 149, 22, 0, 0, 0, 0, 0, 0, 0, 93, 148, 40, 75, 1, 75, 2, 93, 148, 40,
  75, 3, 75, 4, 93, 148, 75, 5, 97, 101, 101, 46>>
  test "nested_list" do
    assert {:ok, [1,2,[3, 4,[5]]]} = BakingSoda.load(@nested_list)
  end




end
