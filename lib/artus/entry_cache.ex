defmodule Artus.EntryCache do
  @moduledoc "Module caches entries."
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :entry_cache])
  end

  def init(:ok) do
    {:ok, %{}}
  end

  # Client
  def count do
    GenServer.call(:entry_cache, :count)
  end

  def add(data) do
    GenServer.call(:entry_cache, {:add, data})
  end

  def fetch(id) do
    GenServer.call(:entry_cache, {:fetch, id})
  end

  def submit(id) do
    GenServer.cast(:entry_cache, {:submit, id})
  end

  # Server
  def handle_call(:count, _from, state) do
    {:reply, map_size(state), state}
  end
  def handle_call({:add, data}, _from, state) do
    uuid = UUID.uuid4()
    {:reply, uuid, Map.put(state, uuid, data)}
  end
  def handle_call({:fetch, id}, _from, state) do
    {:reply, state[id], state}
  end
  
  def handle_cast({:submit, id}, state) do
    {:noreply, Map.delete(state, id)}
  end

end
