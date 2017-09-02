defmodule Artus.PageController do
  use Artus.Web, :controller

  def index(conn, _params) do
    notice = Artus.DefinitionManager.get_notice()
    render conn, "index.html", notice: notice
  end

  def nojs(conn, _params) do
    render conn, "nojs.html"
  end
  
  def noie(conn, _params) do
    render conn, "noie.html"
  end

  def about(conn, _params) do
    render conn, "about.html"
  end

  def account(conn, _params) do
    render conn, "account.html"
  end
  
  def imprint(conn, _params) do
    render conn, "imprint.html"
  end

  def feedback(conn, _params) do
    render conn, "feedback.html"
  end

  def submit_feedback(conn, %{"feedback" => feedback}) do
    case feedback["bot"] do
      "" ->
        feedback 
        |> Artus.Email.feedback_email
        |> Artus.Mailer.deliver_now

        conn
        |> put_flash(:info, "Thanks for your feedback!")
        |> redirect(to: page_path(conn, :feedback))
      _ ->
        conn
        |> put_flash(:error, "Nope.")
        |> redirect(to: page_path(conn, :feedback))
    end
  end
  
  def show(conn, %{"id" => id}) do
  end

end
