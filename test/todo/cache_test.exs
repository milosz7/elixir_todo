defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    a_pid = cache |> Todo.Cache.server_process("a")

    assert a_pid == Todo.Cache.server_process(cache, "a")
    assert a_pid != Todo.Cache.server_process(cache, "b")
  end
end
