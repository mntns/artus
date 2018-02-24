defmodule Artus.FormChannel do
  @moduledoc "Main channel for form interaction"

  use Phoenix.Channel
  import Ecto.Query
  alias Artus.{Entry, EntryCache, DefinitionManager, Tag, Abbreviation, Repo, Cache}

  @doc "Returns socket after join"
  def join("input:form", _message, socket) do
    {:ok, socket}
  end

  @doc "Returns available options for parts and types"
  def handle_in("options", _, socket) do
    opts = DefinitionManager.options()
    {:reply, {:ok, %{options: opts}}, socket}
  end

  @doc "Returns available fields by type"
  def handle_in("fields", %{"type" => type}, socket) do
    field_defs = DefinitionManager.field_defs()
    actual_fields = DefinitionManager.fields()
    fields = actual_fields[type]
             |> Enum.map(fn([id|req]) ->
                          definition = field_defs[id]
                          Map.merge(%{id: id, required: hd(req)}, definition)
                        end)
    {:reply, {:ok, %{fields: fields}}, socket}
  end

  @doc "Returns modal data by ID"
  def handle_in("modal", %{"id" => id}, socket) do
    body = DefinitionManager.get_modal(id)
    field = DefinitionManager.get_field(id)
    {:reply, {:ok, %{title: field["label"], body: body}}, socket}
  end

  @doc "Returns available languages"
  def handle_in("languages", _, socket) do
    languages = DefinitionManager.languages()
    {:reply, {:ok, %{languages: languages}}, socket}
  end

  @doc "Returns abbreviation by ID"
  def handle_in("abbreviations", %{"id" => id}, socket) do
    abbr = Repo.get!(Abbreviation, id)
    payload = %{title: abbr.title, issn: abbr.issn, place: abbr.place, publisher: abbr.publisher}
    {:reply, {:ok, %{abbreviation: payload}}, socket}
  end

  @doc "Returns all abbreviations"
  def handle_in("abbreviations", _, socket) do
    abbr = Abbreviation
           |> Repo.all
           |> Enum.map(fn(x) -> %{id: x.id, abbr: x.abbr, title: x.title} end)
    {:reply, {:ok, %{abbreviations: abbr}}, socket}
  end

  @doc "Returns all caches of user"
  def handle_in("caches", _, socket) do
    user = Repo.get!(Artus.User, socket.assigns.user)
    query = user
            |> Ecto.assoc(:caches)
            |> select([c], {c.id, c.name})
    caches = query
             |> Repo.all
             |> Enum.map(fn({id, name}) -> %{value: id, label: name} end)
    {:reply, {:ok, %{caches: caches}}, socket}
  end

  @doc "Returns entry by ID"
  def handle_in("entries", %{"id" => id}, socket) do
    to_take = [:type, :part, :biblio_record_id,
               :author, :editor, :editor_primary_work,
               :reviewer, :titl_title, :titl_subtitle,
               :titl_add, :ser_title, :ser_volume, :ser_code, :ser_issue,
               :ser_count, :ser_year_pub, :publ_pub_house,
               :publ_pub_place, :biblio_issn, :biblio_isbn,
               :doi, :abstract, :language, :subject_things,
               :subject_works, :additional_info, :links,
               :internal_comment, :id, :cache_id]
    entry = Artus.Entry
            |> Repo.get!(id)
            |> Map.from_struct
            |> Map.take(to_take)

    # Update cache
    cache = Repo.get!(Artus.Cache, entry[:cache_id])
    entry = Map.put(entry, :cache, %{value: cache.id, label: cache.name})

    # Update type and parts
    options = Artus.DefinitionManager.options()
    type_map = options["types"] |> Enum.find(fn(x) -> x["value"] == entry[:type] end)
    part_map = options["parts"] |> Enum.find(fn(x) -> x["value"] == entry[:part] end)

    # Update ser_code
    query = from a in Abbreviation, where: a.abbr == ^entry[:ser_code]
    abbreviation = Repo.one(query)
    entry = %{entry | ser_code: %{id: abbreviation.id, title: abbreviation.title, abbr: abbreviation.abbr}}

    entry = %{entry | type: type_map}
    entry = %{entry | part: part_map}

    {:reply, {:ok, %{entry: entry}}, socket}
  end

  @doc "Returns parent entry by ID"
  def handle_in("saved_parent_entry", %{"id" => id}, socket) do
    to_take = [:editor, :editor_primary_work, :reviewer,
               :titl_add, :ser_volume, :ser_code, :ser_issue,
               :ser_count, :ser_year_pub, :publ_pub_house,
               :publ_pub_place, :biblio_issn, :biblio_isbn,
               :doi, :additional_info, :links,
               :internal_comment]
    entry = Artus.Entry
            |> Repo.get!(id)
            |> Map.from_struct
            |> Map.take(to_take)
    {:reply, {:ok, %{entry: entry}}, socket}
  end
  
  @doc "Updates already existing entry and returns URL of associated cache"
  def handle_in("submit", %{"data" => data, "entry" => entry_id}, socket) do
    user = Repo.get!(Artus.User, socket.assigns.user)
    entry = Artus.Entry
            |> Repo.get!(entry_id)
            |> Repo.preload([:cache, :user, :bibliograph])
    cache = Repo.get!(Artus.Cache, data["cache"]["value"])
    changeset = Entry.submit_changeset(entry, user, cache, data)
    
    case Repo.update(changeset) do
      {:ok, entry} -> 
        data = %{id: entry.id, url: Artus.Router.Helpers.cache_path(socket, :show, cache.id, success: "edit")}
        {:reply, {:ok, data}, socket}
      {:error, changeset} -> {:reply, {:err, %{}}, socket}
    end
  end
  
  @doc "Creates new entry and returns URL of associated cache"
  def handle_in("submit", %{"data" => data}, socket) do
    user = Repo.get!(Artus.User, socket.assigns.user)
    cache = Repo.get!(Artus.Cache, data["cache"]["value"])
    changeset = Entry.submit_changeset(%Entry{}, user, cache, data)
    
    case Repo.insert(changeset) do
      {:ok, entry} -> 
        data = %{id: entry.id, url: Artus.Router.Helpers.cache_path(socket, :show, cache.id, success: "create")}
        {:reply, {:ok, data}, socket}
      {:error, changeset} -> {:reply, {:err, %{}}, socket}
    end
  end
end
