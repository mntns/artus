defmodule Artus.FastSearchServer do
  @moduledoc "Server that stores tries for fast, simple queries"
  use GenServer
  import Ecto.Query

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :fast_search])
  end

  def init(:ok) do
    GenServer.cast(:fast_search, :build_tree)
    {:ok, []}
  end

  def match(query) do
    GenServer.call(:fast_search, {:match, query})
  end

  def handle_call({:match, query}, _from, state) do
    {:reply, Retrieval.prefix(state.trie, query), state}
  end

  def handle_cast(:build_tree, state) do
    keys = [:titl_title, :titl_subtitle, :editor, :author]
    query = from e in Artus.Entry, select: map(e, ^keys)

    trie = query
           |> Artus.Repo.all()
           |> Enum.map(&tokenize_entry(&1))
           |> List.flatten()
           |> Retrieval.new()

    {:noreply, %{trie: trie}}
  end

  defp tokenize_entry(entry) do
    entry
    |> Enum.map(fn {k,v} -> 
      case is_nil(v) do
        true -> {k, ""}
        false -> {k, v}
      end
    end)
    |> Enum.map(fn {k,v} -> tokenize_field(k, v) end)
  end

  defp tokenize_author(author) do
    case String.split(author, ", ", trim: true) do
      [name, first] ->
        String.downcase(first <> " " <> name)
      [name] ->
        String.downcase(name)
      x -> author
    end
  end

  defp tokenize_field(:author, author) do
    author
    |> String.split(";", trim: true)
    |> Enum.map(&tokenize_author(&1))
  end
  defp tokenize_field(:titl_title, title) do
    title
    |> String.split([".", ";"], trim: true)
    |> Enum.map(&String.downcase(&1))
  end
  defp tokenize_field(:editor, editor), do: tokenize_field(:author, editor)
  defp tokenize_field(:titl_subtitle, subtitle), do: tokenize_field(:titl_title, subtitle)
  defp tokenize_field(_, _), do: []
end
