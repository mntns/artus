defmodule Artus.QueryTest do
  use Artus.ModelCase

  alias Artus.Query

  @valid_attrs %{created_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, request: "some content", uuid: "some content", views: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Query.changeset(%Query{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Query.changeset(%Query{}, @invalid_attrs)
    refute changeset.valid?
  end
end
