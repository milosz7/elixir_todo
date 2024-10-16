defmodule Todo.System do
  def start_link(n_workers \\ 3) do
    children = [Todo.ProcessRegistry, {Todo.Database, n_workers}, Todo.Cache]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
