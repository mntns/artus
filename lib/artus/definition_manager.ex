defmodule Artus.DefinitionManager do
  @moduledoc "Module for dynamically loading definition JSON files"
  use GenServer

  @doc "Starts definition manager"
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [name: :def_manager])
  end

  @doc "Initializes DefinitionManager by reading definitions"
  def init(:ok) do
    defs = read_defs() |> Map.put(:notice, nil)
    {:ok, defs}
  end

  @doc "Hotswaps definitions by rereading them"
  def reread do
    GenServer.cast(:def_manager, :reread)
  end

  @doc "Get modal information by id"
  def get_modal(id) do
    GenServer.call(:def_manager, {:modal, id})
  end
  
  @doc "Get input form field information by id"
  def get_field(id) do
    GenServer.call(:def_manager, {:field, id})
  end

  @doc "Get input form fields for all types"
  def fields do
    GenServer.call(:def_manager, :fields)
  end

  @doc "Get all input field definitions"
  def field_defs do
    GenServer.call(:def_manager, :field_defs)
  end

  @doc "Get all languages"
  def languages do
    GenServer.call(:def_manager, :languages)
  end

  @doc "Get all options"
  def options do
    GenServer.call(:def_manager, :options)
  end

  @doc "Get all branches"
  def branches do
    GenServer.call(:def_manager, :branches)
  end

  @doc "Sets public notice"
  def set_notice(notice) do
    GenServer.cast(:def_manager, {:set_notice, notice})
  end

  @doc "Gets public notice"
  def get_notice do
    GenServer.call(:def_manager, :get_notice)
  end

  @doc false
  def handle_cast(:reread, _state) do
    {:noreply, read_defs()}
  end
  def handle_cast({:set_notice, notice}, state) do
    {:noreply, %{state | :notice => notice}}
  end

  @doc false
  def handle_call(:fields, _from, state) do
    {:reply, state.fields, state}
  end
  def handle_call(:field_defs, _from, state) do
    {:reply, state.field_defs, state}
  end
  def handle_call(:languages, _from, state) do
    {:reply, state.languages, state}
  end
  def handle_call(:options, _from, state) do
    {:reply, state.options, state}
  end
  def handle_call(:branches, _from, state) do
    {:reply, state.branches, state}
  end
  def handle_call({:modal, id}, _from, state) do
    {:reply, state.modals[id], state}
  end
  def handle_call({:field, id}, _from, state) do
    {:reply, state.field_defs[id], state}
  end
  def handle_call(:get_notice, _from, state) do
    {:reply, state.notice, state}
  end

  @doc "Reads definitions from JSON files in `defs/` and returns map"
  def read_defs do
    ~w(modals field_defs fields languages options branches)
    |> Enum.map(fn(x) -> {String.to_atom(x), "defs/#{x}.json" |> File.read! |> JSX.decode!} end) 
    |> Enum.into(%{})
  end
end
