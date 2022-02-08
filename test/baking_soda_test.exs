defmodule BakingSodaTest do
  use ExUnit.Case
  doctest BakingSoda


  # binary representation of 6 (one byte int)
  @one_byte_int <<128, 4, 75, 6, 46>>
  test "one_byte_int" do
    {:ok, res} = BakingSoda.load(@one_byte_int)
    assert res == 6
  end

  # binary representation of 7312
  @two_byte_int <<128, 4, 149, 4, 0, 0, 0, 0, 0, 0, 0, 77, 144, 28, 46>>
  test "two_byte_int" do
    {:ok, res} = BakingSoda.load(@two_byte_int)
    assert res == 7312
  end

  # binary representation of tuple (1,2)
  @tuple2 <<128, 4, 149, 7, 0, 0, 0, 0, 0, 0, 0, 75, 1, 75, 2, 134, 148, 46>>
  test "tuple" do
    {:ok, res} = BakingSoda.load(@tuple2)
    assert res == {1,2}
  end

  # binary representation of tuple (1,2,3)
  @tuple3 <<128, 4, 149, 9, 0, 0, 0, 0, 0, 0, 0, 75, 1, 75, 2, 75, 3, 135, 148, 46>>
  test "tuple3" do
    {:ok, res} = BakingSoda.load(@tuple3)
    assert res == {1,2,3}
  end

  # binary representation of nested tuple (1, 2, (3, 4))
  @nested_tuple <<128, 4, 149, 13, 0, 0, 0, 0, 0, 0, 0, 75, 1, 75, 2, 75, 3, 75, 4, 134, 148,
  135, 148, 46>>
  test "nested_tuple" do
    {:ok, res} = BakingSoda.load(@nested_tuple)
    assert res == {1,2,{3,4}}
  end

  # binary representation of double 1.0
  @float <<128, 4, 149, 10, 0, 0, 0, 0, 0, 0, 0, 71, 63, 240, 0, 0, 0, 0, 0, 0, 46>>
  test "float" do
    {:ok, res} = BakingSoda.load(@float)
    assert res == 1.0
  end




end
