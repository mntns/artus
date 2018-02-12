defmodule Artus.ModalController do
  use Artus.Web, :controller
  alias Artus.DefinitionManager

  @doc "Returns field title and modal content as JSON"
  def modal(conn, %{"id" => id}) do
    body = DefinitionManager.get_modal(id)
    field = DefinitionManager.get_field(id)

    json conn, %{title: field["label"], body: body}
  end
end
