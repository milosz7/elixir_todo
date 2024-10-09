defmodule Todo.DatabaseTest do
  use ExUnit.Case
  @persist "./data"
  @test_todo_list_name "db_test"

  test "TodoList persistance test" do
    {:ok, cache} = Todo.Cache.start()
    server = cache |> Todo.Cache.server_process(@test_todo_list_name)

    server |> Todo.Server.add_entry(%{date: ~D[2018-12-19], title: "Dentist"})
    server |> Todo.Server.add_entry(%{date: ~D[2018-12-20], title: "Shopping"})
    server |> Todo.Server.add_entry(%{date: ~D[2018-12-19], title: "Movies"})

    Process.exit(cache, :normal)

    {:ok, cache} = Todo.Cache.start()
    server = cache |> Todo.Cache.server_process(@test_todo_list_name)

    assert server |> Todo.Server.entries(~D[2018-12-19]) |> length() == 2

    # cleanup
    File.rm(Path.join([@persist, @test_todo_list_name]))
  end
end
