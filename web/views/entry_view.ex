defmodule Artus.EntryView do
  use Artus.Web, :view

  import Ecto.Query
  alias Artus.Repo
  alias Artus.Tag
  alias Artus.Cache

  def render_tag(tag) do
    tag.tag |> NotMarkdown.to_html()
  end

  def get_label(key) do
    field_defs = Artus.DefinitionManager.field_defs
    case field_defs[key] do
      nil -> inspect key
      "type" -> "Type"
      x -> x["label"]
    end
  end

  def get_language(language) do
    lang_defs = Artus.DefinitionManager.languages
    l_filtered = lang_defs |> Enum.filter(fn(l) -> l["value"] == language end) |> hd
    l_filtered["label"]
  end

  def get_part(part_number) do
    if part_number == 3 do
      "Reprint"
    else
      option_defs = Artus.DefinitionManager.options
      o_filtered = option_defs["parts"] 
                   |> Enum.filter(fn(o) -> o["value"] == part_number end) |> hd
      o_filtered["label"]
    end
  end
  
  def get_type(type) do
    if type == "r" do
      "Review"
    else
      option_defs = Artus.DefinitionManager.options
      o_filtered = option_defs["types"] |> Enum.filter(fn(o) -> o["value"] == type end) |> hd
      o_filtered["label"]
    end
  end

  def doi_link(doi) do
    "https://dx.doi.org/" <> doi
  end

  def get_branch(branch_int) do
    branches = Artus.DefinitionManager.branches
    case branches["#{branch_int}"] do
      x -> x
    end
  end

  def belongs_to_user?(user_id, entry_id) do
    query = from c in Cache,
            where: c.user == ^(user_id),
            select: c.entries
    query |> Repo.all |> List.flatten |> Enum.member?(entry_id)
  end

end
