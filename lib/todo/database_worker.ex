defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({data_path, worker_id}) do
    GenServer.start_link(
      __MODULE__,
      data_path,
      name: via_tuple(worker_id)
    )
  end

  def get(worker_id, key) do
    worker_id
    |> via_tuple()
    |> GenServer.call({:get, key})
  end

  def store(worker_id, key, data) do
    worker_id
    |> via_tuple()
    |> GenServer.cast({:store, key, data})
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  @impl true
  def init(data_path) do
    IO.puts("Starting worker process")
    {:ok, data_path}
  end

  @impl true
  def handle_cast({:store, key, data}, data_path) do
    file_name(data_path, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, data_path}
  end

  @impl true
  def handle_call({:get, key}, _from, data_path) do
    data =
      case File.read(file_name(data_path, key)) do
        {:ok, binary} -> :erlang.binary_to_term(binary)
        _ -> nil
      end

    {:reply, data, data_path}
  end

  defp file_name(folder, key) do
    Path.join([folder, key])
  end
end
