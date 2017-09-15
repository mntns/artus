defmodule Artus.EntryController do
  use Artus.Web, :controller

  import Ecto.Query
  alias Artus.Entry
  alias Artus.Cache
  alias Artus.User

  def show(conn, %{"id" => id}) do
    entry = Entry |> Repo.get!(id) |> Repo.preload([:tags, :bibliograph, :cache, :reviews, :reprints, :children])
    case user = conn.assigns.user do
      nil ->
        render conn, "show.html", %{entry: entry, user_caches: [], is_owner: false}
      user ->
        user_id = user.id
        user = Repo.get!(User, user_id)
        user_caches = case entry.cache do 
                        nil -> []
                        _ -> user |> Ecto.assoc(:caches) |> where([c], c.id != ^entry.cache.id) |> Repo.all
                      end
                      is_owner = case cache = entry.cache do
                        nil ->
                          false
                        _ ->
                          cache = cache |> Repo.preload(:user)
                          case cache.user.id do
                          ^user_id -> true
                          _ -> false
                          end
                      end
        render conn, "show.html", %{entry: entry, user_caches: user_caches, is_owner: is_owner}
    end
  end

  def review(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "review.html", parent_id: entry.id
  end

  def reprint(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "reprint.html", parent_id: entry.id
  end

  def child(conn, %{"id" => id}) do
    # TODO: check if type b
    entry = Repo.get!(Entry, id)
    render conn, "child.html", parent_id: entry.id
  end

  def move(conn, %{"id" => id, "target" => target}) do
    target_cache = Repo.get!(Cache, target)

    Entry
    |> Repo.get!(id)
    |> Repo.preload([:bibliograph, :cache, :reviews, :reprints])
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:cache, target_cache)
    |> Repo.update!()
    
    conn
    |> put_flash(:info, "Successfully moved entry to working cache '#{target_cache.name}'.")
    |> redirect(to: entry_path(conn, :show, id))
  end

  def link(conn, %{"id" => id, "target" => %{"target" => target}}) do
    # TODO: Refactor matching if clause to case
    if (target = Repo.get(Entry, target)) != nil do
      parent_entry = Repo.get!(Entry, id) 
      target = target |> Repo.preload([:bibliograph, :cache, :reviews, :reprints, :children, :children_parent])

      changeset = target
                |> Ecto.Changeset.change
                |> Ecto.Changeset.put_assoc(:children_parent, parent_entry)

      changeset |> Repo.update!()

      conn
      |> put_flash(:info, "Successfully linked child entry")
      |> redirect(to: entry_path(conn, :show, id))
    else
      conn
      |> put_flash(:error, "The entry id you wanted to link to is invalid.")
      |> redirect(to: entry_path(conn, :show, id))
    end
  end

  def remove_link(conn, %{"id" => id, "target" => target_id}) do
    target = Entry
             |> Repo.get!(target_id)
             |> Repo.preload([:bibliograph, :cache, :reviews, :reprints, :children, :children_parent])
    
    changeset = target
                |> Ecto.Changeset.change
                |> Ecto.Changeset.put_assoc(:children_parent, nil)

    changeset |> Repo.update!()
    
    conn
    |> put_flash(:info, "Successfully removed link to child ##{target_id}.")
    |> redirect(to: entry_path(conn, :show, id))
  end

  def edit(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "edit.html", entry: entry
  end

  def export(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "export.html", entry: entry
  end

  def export_type(conn, %{"id" => id, "type" => type}) do
    entry = Repo.get!(Entry, id)
    export_root = "~/artus/artus/export/"

    input = Phoenix.View.render_to_string(Artus.SharedView, "entry.html", entry: entry)
    {:ok, file} = File.open(Path.expand(export_root <> "bias_export_#{id}.html"), [:write, :utf8])
    IO.write file, input
    File.close file
    
    filename = "bias_export_#{id}.#{type}"
    case type do
      "rtf" ->
        convert_file(filename, id)
      "latex" ->
        convert_file(filename, id)
      "odt" ->
        convert_file(filename, id)
    end

    conn
    |> put_resp_header("content-disposition", 
                       ~s(attachment; filename="#{filename}"))
    |>send_file(200, Path.expand(export_root <> filename))
  end

  defp convert_file(filename, id) do
    System.cmd("pandoc", ["-s", "-o", filename, "bias_export_#{id}.html"], cd: "/home/mono/artus/artus/export")
  end
    
  def delete(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    Repo.delete!(entry)

    conn 
    |> put_flash(:info, "Entry deleted successfully.")
    |> redirect(to: page_path(conn, :index))
  end

end
