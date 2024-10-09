defmodule Todo.Database do
  use GenServer

  @data_folder "./data"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    File.mkdir_p!(@data_folder)
    {:ok, nil}
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl true
  def handle_cast({:store, key, data}, state) do
    file_name(key)
    |> File.write(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    data =
      case File.read(file_name(key)) do
        {:ok, binary} -> :erlang.binary_to_term(binary)
        _ -> nil
      end

    IO.inspect(data)

    {:reply, data, state}
  end

  defp file_name(key) do
    Path.join([@data_folder, key])
  end
end
