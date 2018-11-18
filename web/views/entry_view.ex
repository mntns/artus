defmodule Artus.EntryView do
  use Artus.Web, :view

  import Ecto.Query
  alias Artus.Repo
  alias Artus.Tag
  alias Artus.Cache

  # TODO: Branch in Entry? Part/Type in Entry?

  def render_tag(tag) do
    tag.tag |> Artus.NotMarkdown.to_html()
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

  @doc "Returns DOI referer link"
  def doi_link(doi) do
    # TODO: Check DOI with Regex
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
  
  @doc """
  Prepares entry for table rendering

  It fetches the keys from the `DefinitionManager` and
  builds a keyword list using the keys and the entry
  """
  def prepare_entry_table(entry) do
    entry_map = Map.from_struct(entry)
    to_remove = [:abstract, :internal_comment]
    
    Artus.DefinitionManager.fields()[entry.type]
    |> Enum.map(fn [k, _] -> String.to_atom(k) end)
    |> (&(&1 -- to_remove)).()
    |> Enum.map(fn(k) -> {k, entry_map[k]} end)
    |> Enum.filter(fn({k, v}) -> !is_nil(v) end)
  end


  def render_label(:part), do: "Part"
  def render_label(:type), do: "Type"
  def render_label(:editor), do: "Editor(s)"
  def render_label(key) do
    key |> Atom.to_string |> get_label()
  end

  def render_value(:editor, value) do
    value |> Artus.SharedView.style_editors() |> raw()
  end
  def render_value(:author, value) do
    value |> Artus.SharedView.style_authors() |> raw()
  end
  def render_value(:part, value) do
    get_part(value)
  end
  def render_value(:doi, value) do
    render Artus.EntryView, "field_doi.html", %{doi: value}
  end
  def render_value(:language, value) do
    language_map = Artus.DefinitionManager.languages()
                   |> Enum.filter(fn(m) -> m["value"] == value end)
                   |> hd()
    case language_map["label"] do
      nil -> value
      x -> x
    end
  end
  def render_value(:links, value) do
    # TODO: Refactor field_links.html
    render Artus.EntryView, "field_links.html", %{links: value}
  end
  def render_value(key, value) do
    value
  end


  def render_entry_status(entry) do
    case entry.public do
      true -> "<span class=\"badge badge-pill badge-success\">Public</span>"
      false -> "<span class=\"badge badge-pill badge-warning\">Not public</span>"
    end
  end

end
