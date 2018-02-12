defmodule Artus.InputController do
  use Artus.Web, :controller
  alias Artus.{Entry, Cache}

  @doc "Renders input form with fixed cache"
  def input(conn, %{"cache" => cache_id}) do
    cache = Repo.get!(Cache, cache_id)
    render conn, "input.html", %{cache: cache}
  end
  
  @doc "Renders input form"
  def input(conn, _params) do
    render conn, "input.html", %{cache: nil}
  end
end
