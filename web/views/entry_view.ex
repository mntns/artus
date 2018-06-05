defmodule Artus.EntryView do
  use Artus.Web, :view

  import Ecto.Query
  alias Artus.Repo
  alias Artus.Tag
  alias Artus.Cache

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
  
  # <%= case key do %>
  #               <% :doi -> %>
  #                 <th scope="row">Digital Object Identifier</th>
  #                 <td>
  #                   <a target="_blank" href="<%= doi_link(@entry.doi) %>"><%= @entry.doi %></a>
  #                 </td>

  #                 <% :links -> %>
  #                   <th scope="row">Links</th>
  #                   <td>
  #                     <%= for line <- String.split(value, "\n", trim: true) do %>
  #                       <% link_set = String.split(line, " ") %>
  #                       <a href="<%= hd(link_set) %>"><%= List.last(link_set) %></a>
  #                     <% end %>
  #                   </td>
  #                   <% :part -> %>
  #                     <th scope="row">Part</th>
  #                     <td><%= get_part(value) %></td>
  #                     <% :type -> %>
  #                       <th scope="row">Type</th>
  #                       <td><%= get_type(value) %></td>
  #                       <% :branch -> %>
  #                         <th scope="row">Branch</th>
  #                         <td>
  #                           <% branch = get_branch(@entry.branch) %>
  #                           <%= for flag <- branch["flags"] do %>
  #                             <span class="flag-icon flag-icon-<%= flag %>"></span>
  #                           <% end %>
  #                           (<%= branch["name"] %>)
  #                         </td>
  #                         <% _ -> %>
  #                           <th scope="row"><%= key |> Atom.to_string |> get_label %></th>
  #                           <td><%= value %></td>
  #                         <% end %>
  #
  #                         
  
  def prepare_entry(entry) do
    field_keys = Artus.DefinitionManager.field_defs()
                 |> Map.keys()
                 |> Enum.map(&String.to_atom(&1))

    entry
    |> Map.from_struct()
    |> Enum.filter(fn({k,v}) -> Enum.member?(field_keys, k) && !is_nil(v) && k != :abstract end)
  end


  def render_label(:part), do: "Part"
  def render_label(:type), do: "Type"
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
  def render_value(key, value) do
    value
  end


end
