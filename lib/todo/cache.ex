defmodule Todo.Cache do
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  def server_process(cache_pid, name) do
    GenServer.call(cache_pid, {:server_process, name})
  end

  @impl true
  def handle_call({:server_process, name}, _from, todo_servers) do
    case Map.fetch(todo_servers, name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        cached_list = Todo.Database.get(name)
        {:ok, new_server} = Todo.Server.start(name, cached_list)
        {:reply, new_server, Map.put(todo_servers, name, new_server)}
    end
  end
end
