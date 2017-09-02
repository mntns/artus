defmodule Artus.AbbreviationTest do
  use Artus.ModelCase

  alias Artus.Abbreviation

  @valid_attrs %{abbr: "some content", issn: "some content", place: "some content", publisher: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Abbreviation.changeset(%Abbreviation{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Abbreviation.changeset(%Abbreviation{}, @invalid_attrs)
    refute changeset.valid?
  end
end
