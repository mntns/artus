defmodule Artus.InputController do
  @moduledoc "Controller for the default entry input form"

  use Artus.Web, :controller
  alias Artus.Cache

  @doc "Renders input form (optionally with fixed cache ID)"
  def input(conn, %{"cache" => cache_id}) do
    cache = Repo.get!(Cache, cache_id)
    render conn, "input.html", %{cache: cache}
  end
  def input(conn, _params) do
    render conn, "input.html", %{cache: nil}
  end
end
