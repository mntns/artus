# mix run priv/repo/seeds.exs

defmodule Artus.Seeder do
  require Logger
  alias Artus.Repo
  alias Artus.Abbreviation
  alias Artus.User
  alias Artus.Tag

  @doc "Populate abbreviations from JSON file"
  def populate_abbreviations do
    "priv/repo/seed_sources/abbreviations.json"
    |> File.read!
    |> JSX.decode!
    |> Enum.map(&insert_abbreviation(&1))

    Logger.debug "Successfully populated abbreviations."
  end

  defp insert_abbreviation(abbr) do
    Abbreviation.changeset(%Abbreviation{}, abbr)
    |> Repo.insert!
  end

  @doc "Populate tags from plaintext files"
  def populate_tags do
    "priv/repo/seed_sources/subject_things.txt"
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.map(&insert_tag(&1, 1))

    "priv/repo/seed_sources/subject_works.txt"
    |> File.read!
    |> String.split("\n", trim: true)
    |> Enum.map(&insert_tag(&1, 2))

    Logger.debug "Successfully populated tags."
  end

  defp insert_tag(tag_raw, type) do
    Tag.changeset(%Tag{}, %{tag: tag_raw, type: type, user_tag: false})
    |> Repo.insert!
  end

  @doc "Create admin user account"
  def create_admin_account do
    options = %{
      name: "Eddy Shure",
      hash: "$2b$12$U/kgnWuJBbnQCHDf3zcaSOUbB/6jb7vC9XnbzNz6AVKkJ0/2HbJr.",
      mail: "artus@monoton.space",
      branch: 5,
      admin: true,
      activated: true,
      activation_code: nil,
      level: 3}

    User.changeset(%User{}, options)
    |> Repo.insert!

    Logger.debug "Successfully create admin account."
  end
end

Artus.Seeder.create_admin_account()
Artus.Seeder.populate_abbreviations()
Artus.Seeder.populate_tags()
