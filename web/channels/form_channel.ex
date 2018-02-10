defmodule Artus.FormChannel do
  @moduledoc "Main channel for form interaction"
  use Phoenix.Channel
  alias Artus.DefinitionManager
  import Ecto.Query
  alias Artus.Tag
  alias Artus.Abbreviation
  alias Artus.Repo
  alias Artus.Cache

  def join("input:form", _message, socket) do
    {:ok, socket}
  end

  def handle_in("options", _, socket) do
    opts = DefinitionManager.options
    {:reply, {:ok, %{options: opts}}, socket}
  end
  def handle_in("fields", %{"type" => type}, socket) do
    field_defs = DefinitionManager.field_defs
    actual_fields = DefinitionManager.fields
    fields = actual_fields[type]
             |> Enum.map(fn([id|req]) ->
                          definition = field_defs[id]
                          Map.merge(%{id: id, required: hd(req)}, definition)
                        end)
    {:reply, {:ok, %{fields: fields}}, socket}
  end
  def handle_in("modal", %{"id" => id}, socket) do
    body = DefinitionManager.get_modal(id)
    field = DefinitionManager.get_field(id)
    {:reply, {:ok, %{title: field["label"], body: body}}, socket}
  end
  def handle_in("languages", _, socket) do
    languages = DefinitionManager.languages
    {:reply, {:ok, %{languages: languages}}, socket}
  end
  def handle_in("tags", %{"type" => "subject_things"}, socket) do
    tags = 1 |> fetch_tags |> render_tags
    {:reply, {:ok, %{tags: tags}}, socket}
  end
  def handle_in("tags", %{"type" => "subject_works"}, socket) do
    tags = 2 |> fetch_tags |> render_tags
    {:reply, {:ok, %{tags: tags}}, socket}
  end
  def handle_in("abbreviations", %{"id" => id}, socket) do
    abbr = Repo.get!(Abbreviation, id)
    payload = %{abbr: abbr.abbr, title: abbr.title, issn: abbr.issn, place: abbr.place, publisher: abbr.publisher}
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("abbreviations", _, socket) do
    abbr = Abbreviation
           |> Repo.all
           |> Enum.map(fn(x) -> %{id: x.id, abbr: x.abbr, title: x.title} end)
    {:reply, {:ok, %{abbreviations: abbr}}, socket}
  end

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
  def handle_in("cached_entry", %{"id" => id}, socket) do
    cached_entry = Artus.EntryCache.fetch(id)
    {:reply, {:ok, %{entry: cached_entry}}, socket}
  end
  def handle_in("saved_entry", %{"id" => id}, socket) do
    to_take = [:type, :part, :biblio_record_id,
               :author, :editor, :editor_primary_work,
               :reviewer, :titl_title, :titl_subtitle,
               :titl_add, :ser_volume, :ser_code, :ser_issue,
               :ser_count, :ser_year_pub, :publ_pub_house,
               :publ_pub_place, :biblio_issn, :biblio_isbn,
               :doi, :abstract, :language, :subject_things,
               :subject_works, :additional_info, :links,
               :internal_comment, :id, :cache_id]
    entry = Artus.Entry
            |> Repo.get!(id)
            |> Map.from_struct
            |> Map.take(to_take)
    {:reply, {:ok, %{entry: entry}}, socket}
  end
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
  def handle_in("submit", %{"data" => data}, socket) do
    id = data
         |> Enum.filter(fn({k, v}) -> filter_element(v) end)
         |> Enum.into(%{})
         |> Artus.EntryCache.add()
    {:reply, {:ok, %{id: id}}, socket}
  end

  def handle_in("advanced", query_data, socket) do
    case Artus.QueryRunner.create(query_data) do
      uuid -> {:reply, {:ok, %{id: uuid}}, socket}
      _ -> {:reply, {:err, %{}}, socket}
    end
  end

  #def handle_in("tags", %{"search" => search}, socket) do
  #  query = from t in Tag, where: ilike(t.tag, ^"%#{search}%")
  #  tags = query |> Repo.all() 
  #  {:reply, {:ok, %{tags: tags}}, socket}
  #end
  
  def handle_in("tags", _params, socket) do
    tags = Repo.all(Tag) |> render_tags()
    {:reply, {:ok, %{tags: tags}}, socket}
  end



  defp fetch_tags(type_int) do
    query = from t in Tag, 
            where: t.type == ^type_int,
            order_by: t.tag
    Repo.all(query)
  end

  defp render_tags(tags) do
    tags |> Enum.map(fn(x) -> %{id: x.id, raw: x.tag, rendered: Artus.NotMarkdown.to_html(x.tag)} end)
  end

  defp filter_element(v) when is_binary(v) do
    String.trim(v) != ""
  end
  defp filter_element(v) do
    !is_nil(v)
  end

end
