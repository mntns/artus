defmodule Artus.PageTitle do
  @suffix "BIAS"

  def page_title(assigns), do: assigns |> get |> put_suffix

  defp put_suffix(nil), do: @suffix
  defp put_suffix(title), do: title <> " - " <> @suffix

  defp get(%{view_module: Artus.Admin.PageView}), do: "Admin"
  defp get(%{view_module: Artus.EntryView, view_template: "show.html", entry: entry}) do
    "Entry #" <> "#{entry.id}"
  end
  defp get(_), do: nil
end
