defmodule Artus.Admin.PageController do
  use Artus.Web, :controller

  @doc "Renders overview page / admin dashboard"
  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc "Fetches and renders statistics"
  def stats(conn, _params) do
    entry_count = Artus.Repo.one(from e in Artus.Entry, select: count("*"))
    user_count = Artus.Repo.one(from u in Artus.User, select: count("*"))
    cache_count = Artus.Repo.one(from c in Artus.Cache, select: count("*"))
    query_count = Artus.Repo.one(from q in Artus.Query, select: count("*"))
    cached_query_count = Artus.QueryRunner.count()

    stats = %{entry_count: entry_count,
              user_count: user_count,
              cache_count: cache_count,
              query_count: query_count,
              cached_query_count: cached_query_count}

    render conn, "stats.html", stats: stats
  end

  def logs(conn, _params) do
    render conn, "logs.html", logs: Artus.EventLogger.get(50)
  end

  def notice(conn, _params) do
    render conn, "notice.html"
  end

  @doc "Returns SQL dump of whole database"
  def backup(conn, _params) do
    date_string = Date.utc_today() |> Date.to_string()
    filename = "BIAS_backup_" <> date_string <> ".sql"

    {fd, file_path} = Temp.open!(filename)
    :os.cmd('pg_dump artus_prod > #{file_path}')
    File.close(fd)
    
    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
    |> send_file(200, file_path)
  end
end
