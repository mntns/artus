defmodule Artus.EntryController do
  use Artus.Web, :controller
  alias Artus.{Entry, Cache}

  @doc "Show entry by ID"
  def show(conn, %{"id" => id}) do
    entry = Entry 
            |> Repo.get!(id) 
            |> Repo.preload([{:user, :caches}, :tags, :bibliograph, :cache, :reviews, :reprints, :children])

    conn_user_id = fetch_user_id(conn)
    
    case entry.user.id do
      ^conn_user_id ->
        render conn, "show.html", %{entry: entry, is_owner: true}
      _ ->
        render conn, "show.html", %{entry: entry, is_owner: false}
    end
  end

  defp fetch_user_id(conn) do
    case conn.assigns.user do
      nil -> 0
      x -> x.id
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

  def article(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "article.html", parent_id: entry.id
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
    |> send_file(200, Path.expand(export_root <> filename))
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
