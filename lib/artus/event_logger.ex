defmodule Artus.EventLogger do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :event_logger])
  end

  def init(:ok) do
    {:ok, []}
  end

  def log(type, user)  do
    GenServer.cast(:event_logger, {:log, type, user})
  end
  
  def get(count) do
    GenServer.call(:event_logger, {:get, count})
  end

  def handle_call({:get, count}, _from, state) do
    {:reply, Enum.take(state, count), state}
  end
  
  def handle_cast({:log, type, user}, state) do
    {:noreply, state ++ [%{:timestamp => DateTime.utc_now(), :type => type, :user => user}]}
  end
end
