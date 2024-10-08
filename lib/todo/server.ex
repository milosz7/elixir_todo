defmodule Todo.Server do
  use GenServer

  @impl true
  def init(entries), do: {:ok, Todo.List.new(entries)}

  def start(entries \\ []), do: GenServer.start(__MODULE__, entries)

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def update_entry(pid, id, func) do
    GenServer.cast(pid, {:update_entry, id, func})
  end

  def delete_entry(pid, id) do
    GenServer.cast(pid, {:delete_entry, id})
  end

  def stop(pid, reason \\ :normal) do
    GenServer.stop(pid, reason)
  end

  @impl true
  def handle_call({:entries, date}, _from, current_todos) do
    {:reply, Todo.List.entries(current_todos, date), current_todos}
  end

  @impl true
  def handle_cast({:add_entry, entry}, current_todos) do
    {:noreply, Todo.List.add_entry(current_todos, entry)}
  end

  @impl true
  def handle_cast({:update_entry, id, func}, current_todos) do
    {:noreply, Todo.List.update_entry(current_todos, id, func)}
  end

  @impl true
  def handle_cast({:delete_entry, id}, current_todos) do
    {:noreply, Todo.List.delete_entry(current_todos, id)}
  end
end
