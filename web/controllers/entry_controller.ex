defmodule Artus.EntryController do
  @moduledoc "Controller for all bibliographic entry pages"

  use Artus.Web, :controller
  alias Artus.{Entry, Cache, EventLogger}

  plug :fetch_entry
  plug :check_public when action in [:show, :export, :export_type]
  plug :check_ownership when action in [:move, :edit, :delete]

  @doc "Shows entry by ID"
  def show(conn, %{"id" => id}) do
    owner = is_owner?(conn.assigns.entry, conn.assigns.user)
    render(conn, "show.html", %{entry: conn.assigns.entry, is_owner: owner})
  end

  @doc "Renders review input form for entry"
  def review(conn, %{"id" => id}) do
    render(conn, "review.html", %{entry: conn.assigns.entry})
  end

  @doc "Renders reprint input form for entry"
  def reprint(conn, %{"id" => id}) do
    render(conn, "reprint.html", %{entry: conn.assigns.entry})
  end

  @doc "Renders article input form for entry"
  def article(conn, %{"id" => id}) do
    render(conn, "article.html", %{entry: conn.assigns.entry})
  end

  @doc "Renders edit form"
  def edit(conn, %{"id" => id}) do
    render(conn, "edit.html", %{entry: conn.assigns.entry})
  end

  @doc "Deletes entry"
  def delete(conn, %{"id" => id}) do
    Repo.delete!(conn.assigns.entry)
    EventLogger.log(:entry_delete, "#{conn.assigns.user.name} deleted entry ##{conn.assigns.entry.id}")

    conn 
    |> put_flash(:info, "Entry deleted successfully.")
    |> redirect(to: NavigationHistory.last_path(conn, 2))
  end

  @doc "Moves entry to target working cache"
  def move(conn, %{"id" => id, "target" => target}) do
    target_cache = Repo.get!(Cache, target)

    conn.assigns.entry
    |> Ecto.Changeset.change
    |> Ecto.Changeset.put_assoc(:cache, target_cache)
    |> Repo.update!()

    EventLogger.log(:entry_move, "#{conn.assigns.user.name} moved entry ##{id} to working cache '#{target_cache.name}' (#{target_cache.id})")

    conn
    |> put_flash(:info, "Successfully moved entry to working cache '#{target_cache.name}'.")
    |> redirect(to: entry_path(conn, :show, id))
  end

  @doc "Renders export page"
  def export(conn, %{"id" => id}) do
    render(conn, "export.html", %{entry: conn.assigns.entry})
  end

  @doc "Exports entry as file"
  def export_type(conn, %{"id" => id, "type" => type}) do
    # Renders entry snippet as HTML
    entry = conn.assigns.entry
    entry_html = Phoenix.View.render_to_string(Artus.SharedView, "entry.html", %{entry: entry})
    base_name = "bias_export_#{entry.id}"

    # Writes rendered entry to temporary file
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

  @doc "Checks if user owns entry or is admin"
  defp is_owner?(entry, user) do
    case user do
      nil -> false
      user -> (!entry.public && (entry.user.id == user.id)) || user.admin
    end
  end

  @doc "Fetches entry and assigns it to connection"
  defp fetch_entry(conn, _) do
    preloads = [{:user, :caches}, :tags, :cache, :reviews, :reprints, :children]
    entry = Entry |> Repo.get!(conn.params["id"]) |> Repo.preload(preloads)
    assign(conn, :entry, entry)
  end

  @doc "Checks if entry is public or accessed by user"
  defp check_public(conn, _) do
    if !is_nil(conn.assigns.user) || conn.assigns.entry.public do
      conn
    else
      conn 
      |> put_flash(:info, "You do not have access to this entry.") 
      |> redirect(to: "/")
      |> halt()
    end
  end

  @doc "Checks ownership (or, alternatively, admin-hood) of entry"
  def check_ownership(conn, _) do
    user = conn.assigns.user

    if is_owner?(conn.assigns.entry, user) do
      conn
    else
      conn
      |> put_flash(:info, "You do not have sufficient rights to perfom this action.")
      |> redirect(to: NavigationHistory.last_path(conn, 1))
      |> halt()
    end
  end
end
