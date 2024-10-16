defmodule Todo.Database do
  use GenServer

  @data_folder "./data"

  def start_link(n_workers \\ 3) do
    GenServer.start_link(__MODULE__, n_workers, name: __MODULE__)
  end

  @impl true
  def init(n_workers) do
    IO.puts("Starting Database server (#{n_workers} workers)")
    File.mkdir_p!(@data_folder)
    {:ok, {init_workers(n_workers), n_workers}}
  end

  defp init_workers(n_workers) do
    0..(n_workers - 1)
    |> Enum.reduce(
      %{},
      fn x, acc ->
        {:ok, pid} = Todo.DatabaseWorker.start_link(@data_folder)
        Map.put(acc, x, pid)
      end
    )
  end

  @impl true
  def handle_call({:choose_worker, name}, _from, {workers, n_workers}) do
    index = :erlang.phash2(name, n_workers)
    {:reply, Map.get(workers, index), {workers, n_workers}}
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

  def choose_worker(name) do
    GenServer.call(__MODULE__, {:choose_worker, name})
  end
end
