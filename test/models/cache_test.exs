defmodule Artus.CacheTest do
  use Artus.ModelCase

  alias Artus.Cache

  @valid_attrs %{name: "some content", user: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Cache.changeset(%Cache{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Cache.changeset(%Cache{}, @invalid_attrs)
    refute changeset.valid?
  end
end
