defmodule Artus.InputView do
  use Artus.Web, :view

  def is_relevant?(key) do
    case key do
      "parentID" -> false
      "systemType" -> false
      _ -> true
    end
  end

  def display_key(k) do
    field_defs = Artus.DefinitionManager.field_defs
    case k do
      "type" -> "Type"
      "cache" -> "Working cache"
      "cache_id" -> "Cache ID"
      "id" -> "Entry ID"
      "part" -> "Part"
      x ->
        if label = field_defs[k]["label"] do
          label
        else
          inspect x
        end
    end
  end

  def display_value("subject_things", v), do: display_tags(v)
  def display_value("subject_works", v), do: display_tags(v)
  def display_value("part", v), do: get_part(v)
  def display_value("type", v), do: get_type(v)
  def display_value("language", v), do: get_language(v)
  def display_value(key, v) do
    "<p>#{v}</p>"
  end

  defp display_tags(tags) do
    tags
    |> Enum.map(fn(tag) -> tag["rendered"] end)
    |> Enum.map(fn(rendered) -> "<span class=\"tag tag-default\">" <> rendered <> "</span> " end)
  end
  
  defp get_part(part_number) do
    if part_number == 3 do
      "Reprint"
    else
      option_defs = Artus.DefinitionManager.options
      o_filtered = option_defs["parts"] 
                   |> Enum.filter(fn(o) -> o["value"] == part_number end) |> hd
      o_filtered["label"]
    end
  end
  
  defp get_type(type) do
    if type == "r" do
      "Review"
    else
      option_defs = Artus.DefinitionManager.options
      o_filtered = option_defs["types"] |> Enum.filter(fn(o) -> o["value"] == type end) |> hd
      o_filtered["label"]
    end
  end
  
  defp get_language(language) do
    lang_defs = Artus.DefinitionManager.languages
    l_filtered = lang_defs |> Enum.filter(fn(l) -> l["value"] == language end) |> hd
    l_filtered["label"]
  end
end
