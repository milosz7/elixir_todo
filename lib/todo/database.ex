defmodule Todo.Database do
  @data_folder "./data"
  @n_workers 3

  def start_link() do
    File.mkdir_p!(@data_folder)
    children = init_workers()
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp init_workers() do
    0..(@n_workers - 1)
    |> Enum.reduce(
      [],
      fn id, children ->
        worker_spec = {Todo.DatabaseWorker, :start_link, [{@data_folder, id}]}
        child = %{id: id, start: worker_spec}
        [child | children]
      end
    )
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @n_workers)
  end

  def store(key, data) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> Todo.DatabaseWorker.get(key)
  end
end
