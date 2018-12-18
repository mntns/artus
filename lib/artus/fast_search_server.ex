defmodule Artus.FastSearchServer do
  @moduledoc "Server that stores tries for fast, simple queries"
  use GenServer
  import Ecto.Query

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :fast_search])
  end

  def init(:ok) do
    GenServer.cast(:fast_search, :build_tree)
    {:ok, %{public: [], non_public: []}}
  end

  def match(query, public) do
    GenServer.call(:fast_search, {:match, %{query: query, public: public}})
  end

  def rebuild() do
    GenServer.cast(:fast_search, :build_tree)
  end

  def add(entry) do
    GenServer.cast(:fast_search, {:add, entry})
  end

  def handle_call({:match, %{query: query, public: public}}, _from, state) do
    pub_result = Retrieval.prefix(state.public, query)

    case public do
      true ->
        {:reply, pub_result, state}
      false ->
        non_result = Retrieval.prefix(state.non_public, query)
        {:reply, pub_result ++ non_result, state}
    end
  end

  def handle_cast({:add, entry}, state) do
    token_list = entry |> tokenize_entry() |> List.flatten()

    if entry.public do
      trie = Retrieval.insert(state.public, token_list)

      {:noreply, %{state | public: trie}}
    else
      trie = Retrieval.insert(state.non_public, token_list)
      {:noreply, %{state | non_public: trie}}
    end
  end

  def handle_cast(:build_tree, state) do
    keys = [:titl_title, :titl_subtitle, :editor, :author]
    query_non = from e in Artus.Entry, select: map(e, ^keys), where: e.public == false
    query_pub = from e in Artus.Entry, select: map(e, ^keys), where: e.public == true

    pub_trie = query_pub
               |> Artus.Repo.all()
               |> Enum.map(&tokenize_entry(&1))
               |> List.flatten()
               |> Retrieval.new()

    non_trie = query_non
               |> Artus.Repo.all()
               |> Enum.map(&tokenize_entry(&1))
               |> List.flatten()
               |> Retrieval.new()

    {:noreply, %{state | public: pub_trie, non_public: non_trie}}
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
    case String.split(author, ",", trim: true) do
      [name, first] ->
        String.downcase(String.trim(first) <> " " <> String.trim(name))
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
