defmodule Artus.Admin.TagController do
  use Artus.Web, :controller
  
  import Ecto.Query
  alias Artus.Tag

  def index(conn, _params) do
    # Get type 1 tags
    things_query = from t in Tag, 
                   where: t.type == 1,
                   order_by: t.tag
    things = Repo.all(things_query)

    # Get type 2 tags
    works_query = from t in Tag, 
                  where: t.type == 2,
                  order_by: t.tag
    works = Repo.all(works_query)

    tags = %{things: things, works: works}

    render conn, "index.html", %{tags: tags}
  end

  def create(conn, %{"tag" => tag, "type" => type}) do
    changeset = Tag.changeset(%Tag{}, %{user_tag: false, tag: tag, type: type})

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Successfully created tag.")
        |> redirect(to: tag_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "An error occured while creating the new tag.")
        |> redirect(to: tag_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = Repo.get!(Tag, id)
    Repo.delete!(tag)

    conn
    |> put_flash(:info, "Successfully deleted tag #{id}.")
    |> redirect(to: tag_path(conn, :index))
  end

end
