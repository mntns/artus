defmodule Artus.Filters do
  @moduledoc "Filter definitions for composable queries"
  import Ecto.Query

  @doc "Filters by title, subtitle, editor and author"
  def all_filter(filter, query) do
    case filter["params"]["string"] do
      nil -> query
      s ->
        from e in query,
        where: e.type != "r",
        where: ilike(e.titl_title, ^("%#{s}%")),
        or_where: ilike(e.titl_subtitle, ^("%#{s}%")),
        or_where: ilike(e.editor, ^("%#{s}%")),
        or_where: ilike(e.author, ^("%#{s}%"))
    end
  end

  @doc "Filters public entries"
  def public_filter(filter, query) do
    case filter["params"]["public"] do
      true ->
        from e in query,
        where: e.public == true
      _ ->
        from e in query,
        where: e.public == false
    end
  end
  
  @doc "Filters by entry title"
  def title_filter(filter, query) do
    case filter["params"]["title"] do
      nil -> query
      t ->
        from e in query, 
        where: e.type != "r",
        where: ilike(e.titl_title, ^("%#{t}%"))
    end
  end

  def subtitle_filter(filter, query) do
    case filter["params"]["subtitle"] do
      nil -> query
      t ->
        from e in query, 
        where: e.type != "r",
        where: ilike(e.titl_subtitle, ^("%#{t}%"))
    end
  end

  def lang_filter(filter, query) do
    case lang = filter["params"]["lang"]["value"] do
      nil -> query
      l -> from e in query, where: e.language == ^l
    end
  end

  def year_filter(filter, query) do
    from = filter["params"]["from"]
    to = filter["params"]["to"]

    case (!is_nil(from) && !is_nil(to)) do
      false -> query
      true ->
        from e in query, 
        where: e.ser_year_pub >= ^filter["params"]["from"],
        where: e.ser_year_pub <= ^filter["params"]["to"]
    end
  end

  def author_filter(filter, query) do
    case filter["params"]["author"] do
      nil -> query
      a ->
        from e in query, 
        where: ilike(e.author, ^("%#{a}%"))
    end
  end

  def editor_filter(filter, query) do
    case filter["params"]["editor"] do
      nil -> query
      e ->
        from e in query, 
        where: ilike(e.editor, ^("%#{e}%"))
    end
  end
end
