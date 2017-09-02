defmodule Artus.Admin.AbbreviationController do
  use Artus.Web, :controller
  
  import Ecto.Query
  alias Artus.Abbreviation

  plug :scrub_params, "abbreviation" when action in [:create, :update]

  def index(conn, _params) do
    query = from a in Abbreviation,
            order_by: a.abbr

    abbr = Repo.all(query)
    render conn, "index.html", %{abbreviations: abbr}
  end

  def new(conn, _params) do
    changeset = Abbreviation.changeset(%Abbreviation{})
    render conn, "new.html", %{changeset: changeset}
  end

  def create(conn, %{"abbreviation" => user_params}) do
    changeset = Abbreviation.changeset(%Abbreviation{}, user_params)
    case Repo.insert(changeset) do
      {:ok, _post} ->
         conn
         |> put_flash(:info, "Abbreviation created successfully.")
         |> redirect(to: abbreviation_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
  
  def show(conn, %{"id" => id}) do
    abbr = Repo.get!(Abbreviation, id)
    render conn, "show.html", %{abbr: abbr}
  end

  def edit(conn, %{"id" => id}) do
    abbr = Repo.get!(Abbreviation, id)
    changeset = Abbreviation.changeset(abbr)
    render conn, "edit.html", %{abbr: abbr, changeset: changeset}
  end

  def delete(conn, %{"id" => id}) do
    abbr = Repo.get!(Abbreviation, id)
    Repo.delete!(abbr)
    
    conn
    |> put_flash(:info, "Abbreviation deleted successfully.")
    |> redirect(to: abbreviation_path(conn, :index))
  end

end
