defmodule Artus.Admin.AbbreviationView do
  use Artus.Web, :view

  def render_tag(string) do
    NotMarkdown.to_html(string)
  end

  def inject_danger(form, field) do
    if form.errors[field] do
      "has-danger"
    end
  end

  def split_places(places) do
    places 
    |> String.split(";") 
    |> Enum.map(fn(place) -> String.strip(place) end)
  end
end
