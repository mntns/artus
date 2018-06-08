defmodule Artus.PageController do
  use Artus.Web, :controller

  @doc "Renders main page"
  def index(conn, _params) do
    notice = Artus.DefinitionManager.get_notice()
    is_user = !is_nil(conn.assigns.user)
    render conn, "index.html", %{notice: notice, is_user: is_user}
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
end
