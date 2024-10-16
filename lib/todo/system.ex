defmodule Todo.System do
  def start_link(n_workers \\ 3) do
    children = [Todo.Cache, {Todo.Database, n_workers}, Todo.ProcessRegistry]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
