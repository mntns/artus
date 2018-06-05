defmodule Artus.QueryRunner do
  @moduledoc "Module caches entries."
  use GenServer

  import Ecto.Query
  alias Artus.Repo
  alias Artus.Entry
  alias Artus.Filters

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :query_runner])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # Client
  def count do
    GenServer.call(:query_runner, :count)
  end

  def create(data) do
    GenServer.call(:query_runner, {:create, data})
  end

  def run(id, params) do
    GenServer.call(:query_runner, {:run, id, params})
  end

  def run_sorted(id, sort) do
    GenServer.call(:query_runner, {:run_sorted, id, sort})
  end

  # Server
  def handle_call(:count, _from, state) do
    {:reply, map_size(state), state}
  end
  def handle_call({:create, data}, _from, state) do
    uuid = UUID.uuid4()
    encoded_query = Poison.encode!(data)
    {:reply, uuid, Map.put(state, uuid, data)}
  end
  def handle_call({:run, id, params}, _from, state) do
    case query_data = state[id] do
      nil ->
        {:reply, {:err, :notfound}, state}
      x ->
        m1 = System.system_time(:millisecond)

        # Fetch query data
        query_data = state[id]
        query = from e in Entry, preload: :reviews
        
        results = query_data["filters"]
                  |> Enum.reduce(query, &build_chain(&1, &2))
                  |> Repo.paginate(params)
        

        # Calculate query time
        m2 = System.system_time(:millisecond)
        query_time = m2 - m1
        
        {:reply, {:ok, query_time, results}, state}
    end
  end
  def handle_call({:run_sorted, id, sort}, _from, state) do
    case query_data = state[id] do
      nil ->
        {:reply, {:err, :notfound}, state}
      x ->
        m1 = System.system_time(:millisecond)

        # Fetch query data
        query_data = state[id]
        query = from e in Entry, select: e
        final = Enum.reduce(query_data["filters"], query, &build_chain(&1, &2))
        final2 = from e in final, order_by: field(e, ^String.to_atom(sort))
        
        results = final2 |> Repo.all() |> Repo.preload(:reviews)
        
        # Calculate query time
        m2 = System.system_time(:millisecond)
        query_time = m2 - m1
        
        {:reply, {:ok, query_time, results}, state}
    end
  end

  defp build_chain(filter, query) do
    case filter["type"] do
      "all" -> Filters.all_filter(filter, query)
      "title" -> Filters.title_filter(filter, query)
      "public" -> Filters.public_filter(filter, query)
      "lang" -> Filters.lang_filter(filter, query)
      "year" -> Filters.year_filter(filter, query)
      "author" -> Filters.author_filter(filter, query)
      "editor" -> Filters.editor_filter(filter, query)
    end
  end


end
