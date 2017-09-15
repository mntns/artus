defmodule Artus.InputController do
  use Artus.Web, :controller

  import Ecto.Query
  alias Artus.Entry
  alias Artus.Cache

  @doc "Render input form"
  def input(conn, _params) do
    render conn, "input.html", %{cache: nil}
  end

  @doc "Render input form with preselected working cache"
  def input_cache(conn, %{"cache_id" => cache_id}) do
    cache = Repo.get(Cache, cache_id)
    render conn, "input.html", %{cache: cache}
  end
  
  @doc "Fetch cached entry and display it" 
  def review(conn, %{"id" => id}) do
    case Artus.EntryCache.fetch(id) do
      nil -> text conn, "cached entry not found"
      x -> render conn, "review.html", %{id: id, entry: x, errors: nil}
    end
  end
  
  @doc "Edit cached entry" 
  def edit(conn, %{"id" => id}) do
    case Artus.EntryCache.fetch(id) do
      nil -> text conn, "cached entry not found"
      x -> render conn, "edit.html", %{entry_id: id, cache: nil}
    end
  end

  defp handle_tag(tag, type) do
    case String.match?("#{tag["id"]}", ~r/[0-9]+/) do
      true ->
        Repo.get(Artus.Tag, tag["id"])
      false ->
        changeset = Artus.Tag.changeset(%Artus.Tag{}, %{user_tag: true, tag: tag["id"], type: type})
        Artus.Repo.insert!(changeset)
    end
  end

  def submit_edit(conn, %{"id" => id}) do
    edit_entry = Artus.EntryCache.fetch(id)
                 |> Map.delete("cache")
                 |> Map.delete("cache_id")

    entry = Artus.Repo.get!(Artus.Entry, edit_entry["id"])
    changeset = Artus.Entry.changeset2(entry, edit_entry)

    Artus.Repo.update!(changeset)

    conn
    |> put_flash(:info, "Successfully edited entry!")
    |> redirect(to: entry_path(conn, :show, entry.id))
  end

  # TODO: Move to changeset (http://blog.plataformatec.com.br/2016/12/many-to-many-and-upserts/)
  def submit(conn, %{"id" => id}) do
    # Get bibliograph and their branch
    bibliograph = conn.assigns.user
    user_branch = bibliograph.branch

    # Fetch entry from EntryCache
    entry = Artus.EntryCache.fetch(id)

    subject_things = []
    subject_works = []

    
    # Build tags
    if (!is_nil(entry["subject_things"]) && !is_nil(entry["subject_works"])) do
      subject_things = entry["subject_things"] |> Enum.map(&handle_tag(&1, 1))
      subject_works = entry["subject_works"] |> Enum.map(&handle_tag(&1, 2))
    end
    tags = subject_things ++ subject_works

    # Remove subject_* from dataset
    entry = Map.drop(entry, ["subject_things", "subject_works"])

    {working_cache, entry} = Map.pop(entry, "cache")

    system_type = entry["systemType"]
    gen = %{"branch" => user_branch, "system_type" => system_type, "tags" => tags} 
    full_entry = Map.merge(entry, gen)
    
    cache = Repo.get!(Cache, working_cache)
    changeset = case system_type do
                  0 -> Entry.changeset(%Artus.Entry{user: bibliograph, bibliograph: bibliograph, cache: cache, public: false}, full_entry)
                  1 ->
                    parent_id = entry["parentID"]
                    parent = Repo.get!(Entry, parent_id)
                    Entry.changeset(%Artus.Entry{user: bibliograph, bibliograph: bibliograph, cache: cache, public: false, review_parent: parent}, full_entry)
                  2 ->
                    parent_id = entry["parentID"]
                    parent = Repo.get!(Entry, parent_id)
                    Entry.changeset(%Artus.Entry{user: bibliograph, bibliograph: bibliograph, cache: cache, public: false, reprint_parent: parent}, full_entry)
                  3 ->
                    parent_id = entry["parentID"]
                    parent = Repo.get!(Entry, parent_id)
                    Entry.changeset(%Artus.Entry{user: bibliograph, bibliograph: bibliograph, cache: cache, public: false, children_parent: parent}, full_entry)
                end

   
    # Insert changeset
    case Repo.insert(changeset) do
      {:ok, entry} ->
        Artus.EntryCache.submit(id) 
        
        entry
        |> Repo.preload(:tags)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:tags, tags)
        |> Repo.update!
        
        redirect(conn, to: cache_path(conn, :index))
      {:error, changeset} ->
        entry = Artus.EntryCache.fetch(id)
        render conn, "review.html", %{id: id, entry: entry, errors: changeset.errors}
    end
  end
end
