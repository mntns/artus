defmodule Artus.EntryTest do
  use Artus.ModelCase

  alias Artus.Entry

  @valid_attrs %{biblio_record_id: "some content", branch: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Entry.changeset(%Entry{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Entry.changeset(%Entry{}, @invalid_attrs)
    refute changeset.valid?
  end
end
