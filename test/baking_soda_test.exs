defmodule BakingSodaTest do
  use ExUnit.Case
  doctest BakingSoda

  test "greets the world" do
    assert BakingSoda.hello() == :world
  end
end
