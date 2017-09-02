defmodule Artus.CacheView do
  use Artus.Web, :view

  def inject_danger(form, field) do
    if form.errors[field] do
      "has-danger"
    end
  end

  def lookup_role(level) do
    case level do
      1 -> "International bibliographer"
      2 -> "National bibliographer"
      3 -> "Bibliographer"
    end
  end

end
