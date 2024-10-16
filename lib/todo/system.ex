defmodule Todo.System do
  def start_link(n_workers \\ 3) do
    Supervisor.start_link([Todo.Cache, {Todo.Database, n_workers}], strategy: :one_for_one)
  end
end
