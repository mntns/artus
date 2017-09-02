defmodule Artus.Admin.PageController do
  use Artus.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

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
end
