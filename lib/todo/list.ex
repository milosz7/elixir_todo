defmodule Todo.List do
  defstruct next_id: 0, entries: %{}

  def new(entries \\ []) do
    entries
    |> Enum.reduce(%Todo.List{}, fn entry, todos -> add_entry(todos, entry) end)
  end

  def add_entry(todos, entry) do
    new_entries = Map.put(todos.entries, todos.next_id, entry)
    %Todo.List{todos | next_id: todos.next_id + 1, entries: new_entries}
  end

  def entries(todos, date) do
    todos.entries
    |> Map.values()
    |> Enum.filter(fn todo -> todo.date == date end)
  end

  def update_entry(todos, id, func) do
    case Map.fetch(todos.entries, id) do
      :error ->
        todos

      {:ok, to_update} ->
        new_entry = func.(to_update)
        new_todos = Map.put(todos.entries, id, new_entry)
        %Todo.List{todos | entries: new_todos}
    end
  end

  def delete_entry(todos, id) do
    filtered =
      todos.entries
      |> Map.reject(fn {key, _val} -> key == id end)

    %Todo.List{todos | entries: filtered}
  end
end

defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(acc, {:cont, entry}) do
    Todo.List.add_entry(acc, entry)
  end

  defp into_callback(acc, :done), do: acc

  defp into_callback(_acc, :halt), do: :ok
end
