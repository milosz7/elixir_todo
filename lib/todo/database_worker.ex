defmodule Todo.DatabaseWorker do
  use GenServer

  def start(data_path) do
    GenServer.start(__MODULE__, data_path)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
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
