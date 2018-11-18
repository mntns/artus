defmodule Artus.QueryView do
  use Artus.Web, :view
  import Scrivener.HTML

  @doc "Returns query information string depending on results"
  def query_info(result_count, query_time) do
    case result_count do
      0 -> "No matching entry was found."
      1 -> "1 result, #{query_time} ms"
      count -> "#{count} results, #{query_time} ms"
    end
  end
end
