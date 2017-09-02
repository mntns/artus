defmodule Artus.Admin.UserView do
  use Artus.Web, :view

  def render_tag(string) do
    NotMarkdown.to_html(string)
  end


  def inject_danger(form, field) do
    if form.errors[field] do
      "has-danger"
    end
  end

  def get_branches do
    Artus.DefinitionManager.branches
  end

  def get_branch(branch_int) do
    branches = Artus.DefinitionManager.branches
    IO.inspect branch_int
    case branches["#{branch_int}"] do
      x -> x
    end
  end

  def get_role(role_int) do
    case role_int do
      3 -> "Bibliographer"
      2 -> "National bibliographer"
      1 -> "International bibliographer"
      _ -> "none"
    end
  end

end
