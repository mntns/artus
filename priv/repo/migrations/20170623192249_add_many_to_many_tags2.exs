defmodule Artus.Repo.Migrations.AddManyToManyTags2 do
  use Ecto.Migration

  def change do
    create table(:entries_tags, primary_key: false) do
      add :entry_id, references(:entries)
      add :tag_id, references(:tags)
    end
  end
end
