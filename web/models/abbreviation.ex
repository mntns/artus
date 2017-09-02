defmodule Artus.Abbreviation do
  use Artus.Web, :model

  schema "abbreviations" do
    field :abbr, :string
    field :title, :string
    field :place, :string
    field :publisher, :string
    field :issn, :string

    timestamps
  end

  @required_fields ~w(abbr title place publisher issn)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:abbr, :title, :place, :publisher, :issn])
    |> validate_required([:abbr, :title])
  end
end
