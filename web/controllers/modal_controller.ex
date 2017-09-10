defmodule Artus.ModalController do
  use Artus.Web, :controller
  import Ecto.Query
  alias Artus.Tag
  alias Artus.Abbreviation
  
  alias Artus.DefinitionManager
  

  @doc "Fetch field title and modal content"
  def modal(conn, %{"id" => id}) do
    body = DefinitionManager.get_modal(id)
    field = DefinitionManager.get_field(id)

    json conn, %{title: field["label"], body: body}
  end

  # Tags
  def tags(conn, %{"type" => "subject_things"}) do
    tags = 1 |> fetch_tags |> render_tags
    json conn, tags
  end
  def tags(conn, %{"type" => "subject_works"}) do
    tags = 2 |> fetch_tags |> render_tags
    json conn, tags
  end

  defp fetch_tags(type_int) do
    query = from t in Tag, where: t.type == ^type_int
    Repo.all(query)
  end

  defp render_tags(tags) do
    tags |> Enum.map(fn(x) -> %{id: x.id, raw: x.tag, rendered: Artus.NotMarkdown.to_html(x.tag)} end)
  end


end
