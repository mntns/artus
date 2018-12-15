defmodule Artus.PageController do
  @moduledoc "Controller for all the public-facing pages"

  use Artus.Web, :controller

  @doc "Renders main page"
  def index(conn, _params) do
    notice = Artus.DefinitionManager.get_notice()
    render conn, "index.html", %{notice: notice}
  end

  @doc "Renders warning for browsers with disabled JS"
  def nojs(conn, _params) do
    render conn, "nojs.html"
  end
  
  @doc "Renders warning for IE users"
  def noie(conn, _params) do
    render conn, "noie.html"
  end

  @doc "Renders about page"
  def about(conn, _params) do
    render conn, "about.html"
  end

  @doc "Renders account page"
  def account(conn, _params) do
    render conn, "account.html"
  end
  
  @doc "Renders imprint"
  def imprint(conn, _params) do
    render conn, "imprint.html"
  end

  @doc "Renders tutorial page"
  def tutorial(conn, _params) do
    render conn, "tutorial.html"
  end
end
