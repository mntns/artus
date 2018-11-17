defmodule Artus.Admin.PageView do
  use Artus.Web, :view

  def render_tag(string) do
    Artus.NotMarkdown.to_html(string)
  end

  def get_log_icon(type) do
    lookup = %{
      :auth_reset => "fa-unlock",
      :auth_login => "fa-sign-in",
      :auth_logout => "fa-sign-out",
      :entry_move => "fa-arrows",
      :entry_delete => "fa-trash",
      :cache_create => "fa-plus",
      :cache_send => "fa-paper-plane",
      :cache_publish => "fa-check",
      :cache_delete => "fa-trash-o"
    }
    Map.fetch!(lookup, type)
  end
end
