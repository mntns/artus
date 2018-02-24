defmodule Artus.Admin.TagController do
  use Artus.Web, :controller

  @doc "Renders list of all tags"
  def index(conn, _params) do
    render conn, "index.html"
  end
end
