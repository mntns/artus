defmodule Artus.Abbreviation do
  @moduledoc "Model for publisher abbreviations"
  use Artus.Web, :model

  schema "abbreviations" do
    field :abbr, :string
    field :title, :string
    field :place, :string
    field :publisher, :string
    field :issn, :string

    timestamps()
  end

  @doc "Creates changeset for abbreviations"
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:abbr, :title, :place, :publisher, :issn])
    |> validate_required([:abbr, :title])
  end
end
