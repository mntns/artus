defmodule Artus.Admin.AbbreviationController do
  use Artus.Web, :controller
  import Ecto.Query
  alias Artus.Abbreviation

  plug :scrub_params, "abbreviation" when action in [:create, :update]

  @doc "Shows page with all abbreviations"
  def index(conn, _params) do
    render conn, "index.html"
  end

  @doc "Shows form for creating new abbreviation"
  def new(conn, _params) do
    changeset = Abbreviation.changeset(%Abbreviation{})
    render conn, "new.html", %{changeset: changeset}
  end

  @doc "Creates new abbreviation"
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
  
  @doc "Shows abbreviation by ID"
  def show(conn, %{"id" => id}) do
    abbr = Repo.get!(Abbreviation, id)
    render conn, "show.html", %{abbr: abbr}
  end

  @doc "Shows edit page for abbreviation"
  def edit(conn, %{"id" => id}) do
    abbr = Repo.get!(Abbreviation, id)
    changeset = Abbreviation.changeset(abbr)
    render conn, "edit.html", %{abbr: abbr, changeset: changeset}
  end

  @doc "Deletes abbreviation"
  def delete(conn, %{"id" => id}) do
    abbr = Repo.get!(Abbreviation, id)
    Repo.delete!(abbr)
    
    conn
    |> put_flash(:info, "Abbreviation deleted successfully.")
    |> redirect(to: abbreviation_path(conn, :index))
  end
end
