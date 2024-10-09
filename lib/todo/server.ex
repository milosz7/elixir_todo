defmodule Todo.Server do
  use GenServer

  @impl true
  def init({name, todo_list}) do
    if todo_list do
      {:ok, {name, todo_list}}
    else
      {:ok, {name, Todo.List.new()}}
    end
  end

  def start(name, todo_list \\ nil), do: GenServer.start(__MODULE__, {name, todo_list})

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
  def handle_call({:entries, date}, _from, {name, current_todos}) do
    {:reply, Todo.List.entries(current_todos, date), {name, current_todos}}
  end

  @impl true
  def handle_cast({:add_entry, entry}, {name, current_todos}) do
    new_state = Todo.List.add_entry(current_todos, entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl true
  def handle_cast({:update_entry, id, func}, {name, current_todos}) do
    new_state = Todo.List.update_entry(current_todos, id, func)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl true
  def handle_cast({:delete_entry, id}, {name, current_todos}) do
    new_state = Todo.List.delete_entry(current_todos, id)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end
end
