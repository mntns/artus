defmodule Artus.EntryController do
  use Artus.Web, :controller
  alias Artus.{Entry, Cache}

  plug :check_public_access

  @doc "Show entry by ID"
  def show(conn, %{"id" => id}) do
    entry = Entry 
            |> Repo.get!(id) 
            |> Repo.preload([{:user, :caches}, :tags, :cache, :reviews, :reprints, :children])

    is_owner = case conn.assigns.user do
      nil -> false
      x -> (x.id == entry.user.id)
    end

    render conn, "show.html", %{entry: entry, is_owner: is_owner}
  end

  def review(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "review.html", %{entry: entry}
  end

  def reprint(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "reprint.html", %{entry: entry}
  end

  def article(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "article.html", %{entry: entry}
  end

  def move(conn, %{"id" => id, "target" => target}) do
    target_cache = Repo.get!(Cache, target)

    Entry
    |> Repo.get!(id)
    |> Repo.preload([:cache, :reviews, :reprints])
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:cache, target_cache)
    |> Repo.update!()
    
    conn
    |> put_flash(:info, "Successfully moved entry to working cache '#{target_cache.name}'.")
    |> redirect(to: entry_path(conn, :show, id))
  end

  @doc "Renders edit form"
  def edit(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "edit.html", %{entry: entry}
  end
  
  @doc "Deletes entry"
  def delete(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    Repo.delete!(entry)

    conn 
    |> put_flash(:info, "Entry deleted successfully.")
    |> redirect(to: page_path(conn, :index))
  end

  @doc "Renders export page"
  def export(conn, %{"id" => id}) do
    entry = Repo.get!(Entry, id)
    render conn, "export.html", entry: entry
  end

  @doc "Exports entry as file"
  def export_type(conn, %{"id" => id, "type" => type}) do
    entry = Repo.get!(Entry, id)
    entry_html = Phoenix.View.render_to_string(Artus.SharedView, "entry.html", entry: entry)
    base_name = "bias_export_#{entry.id}"
  
    file_path = Temp.path!(base_name <> ".html")
    fd = File.open!(file_path, [:write, :utf8])
    IO.write(fd, entry_html)
    File.close(fd)

    filetypes = ~w(rtf latex odt)
    case Enum.member?(filetypes, type) do
      true ->
        out_filename = base_name <> "." <> type
        ofile_path = Temp.path!(out_filename)
        convert_file(file_path, ofile_path, type, id)
        
        conn
        |> put_resp_header("content-disposition", ~s(attachment; filename="#{out_filename}"))
        |> send_file(200, ofile_path)
      false ->
        conn
        |> put_flash(:info, "Not an accepted export filetype!")
        |> redirect(to: entry_path(conn, :show, id))
    end
  end

  @doc "Converts html input file to output file of specified type, using pandoc"
  defp convert_file(input, output, type, id) do
    System.cmd("pandoc", [input, "-f", "html", "-t", type, "-s", "-o", output])
  end
  
  @doc "Checks if user that is not logged in has access"
  defp check_public_access(conn, _) do
    entry = Repo.get!(Entry, conn.params["id"])

    case (!is_nil(conn.assigns.user) or entry.public) do
      true -> conn
      false -> 
        conn 
        |> put_flash(:info, "You don’t have access to this entry.") 
        |> redirect(to: "/")
        |> halt()
    end
  end
end
