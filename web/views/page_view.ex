defmodule Artus.PageView do
  use Artus.Web, :view
  def get_branch(branch_int) do
    branches = Artus.DefinitionManager.branches
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
