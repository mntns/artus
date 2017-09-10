defmodule Artus.Admin.PageView do
  use Artus.Web, :view

  def render_tag(string) do
    Artus.NotMarkdown.to_html(string)
  end
end
