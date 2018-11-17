defmodule Artus.QueryController do
  use Artus.Web, :controller
  import Ecto.Query

  # TODO: Refactor this mess
  
  def search(conn, %{"q" => query} = params) do
    opts = case is_nil(conn.assigns.user) do
      true -> %{
          "filters" => [
            %{"type" => "all", "params" => %{"string" => query}},
            %{"type" => "public", "params" => %{"public" => is_nil(conn.assigns.user)}}
          ]}
      false -> %{
          "filters" => [%{"type" => "all", "params" => %{"string" => query}}]
      }
    end
    
    id = Artus.QueryRunner.create(opts)
    {:ok, query_time, results} = Artus.QueryRunner.run(id, params)
    
    render conn, "search.html", %{query: query, query_time: query_time, results: results.entries, page: results}
  end
  
  def advanced(conn, _params) do
    render conn, "advanced.html"
  end

  def query(conn, %{"id"=>id}) do
    case Artus.QueryRunner.run(id) do
      {:err, :notfound} ->
        render conn, "vanished.html"
      {:ok, query_time, results} ->
        render conn, "query.html", %{sort: nil, query_id: id, query_time: query_time, results: results}
    end
  end

  def query_sort(conn, %{"id" => id, "sort" => sort}) do
    case Artus.QueryRunner.run_sorted(id, sort) do
      {:err, :notfound} ->
        render conn, "vanished.html"
      {:ok, query_time, results} ->
        render conn, "query.html", %{sort: sort, query_id: id, query_time: query_time, results: results}
    end
  end
end
