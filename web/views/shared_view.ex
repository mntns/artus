defmodule Artus.SharedView do

  use Artus.Web, :view

  def encap(s) do
    "“" <> s <> "”"
  end 

  def style_titles(title, subtitle) do
    case subtitle do
      nil -> "#{NotMarkdown.to_html("#{title}")}," |> encap
      sub -> "#{NotMarkdown.to_html("#{title}")}. #{NotMarkdown.to_html("#{sub}")}," |> encap
    end
  end

  def style_monograph_titles(title, subtitle) do
    case subtitle do
      nil -> "<i>#{NotMarkdown.to_html("#{title}")}</i>,"
      sub -> "<i>#{NotMarkdown.to_html("#{title}")}</i>. <i>#{NotMarkdown.to_html("#{sub}")}</i>,"
    end
  end


  def style_publ(publ_place) do
    case String.split(publ_place, ";", trim: true) do
      [x] -> x
      x -> Enum.join(x, " /")
    end
  end

  def style_editors(editors) do
    if String.contains?(editors, ["[", "]"]) do
      Regex.replace(~r/[(.+?)]/, editors, fn _, x -> "<span class=\"kapitaelchen\">#{x}</span>" end)
    else
      case String.split(editors, ";", trim: true) do
        [x] ->
          case split = String.split(x, ",", trim: true) do
            [sur, first] ->
              "#{String.trim(first)} <span class=\"kapitaelchen\">#{sur}</span>"
              x -> x
          end
        x ->
          split = Enum.map(x, fn(name) -> 
           case split = String.split(name, ",", trim: true) do
             [sur, first] -> "#{String.trim(first)} <span class=\"kapitaelchen\">#{sur}</span>"
             x -> "#{x}"
           end
          end) |> special_join()
      end
    end
  end

  def style_authors(authors) do
    case String.split(authors, ";", trim: true) do
      [x] ->
        case String.split(x, ",", trim: true) do
          [sur, first] ->
            "<span class=\"kapitaelchen\">#{sur}</span>, #{String.trim(first)}"
          x -> x
        end
      x ->
        # Split in first and last
        [last|firsts] = x |> Enum.reverse
        # Split in first_first and [last_firsts]
        [first_first|last_firsts] = firsts |> Enum.reverse
        firsts_string = [style_specific(first_first)|Enum.map(last_firsts, &style_last(&1))]
                        |> Enum.join(", ")
        last = last |> style_last
        # FIXME: if (length(x) >= 3) do
        firsts_string <> ", and " <> last
    end
  end

  defp special_join(data) do
    if (length(data) >= 3) do
      [last|firsts] = (data |> Enum.reverse)
      (firsts |> Enum.reverse |> Enum.join(", ")) <> ", and " <> String.trim(last)
    else
      [last|firsts] = (data |> Enum.reverse)
      (firsts |> Enum.reverse |> Enum.join(", ")) <> " and " <> String.trim(last)
    end
  end

  defp style_last(author) do
    case String.split(author, ",", trim: true) do
      [sur, first] ->
        "#{String.trim(first)} <span class=\"kapitaelchen\">#{sur}</span>"
      [x] -> String.trim(x)
    end
  end

  defp style_specific(author) do
    case String.split(author, ",", trim: true) do
      [sur, first] ->
        "<span class=\"kapitaelchen\">#{sur}</span> #{String.trim(first)}"
      [x] -> String.trim(x)
    end
  end

end
