defmodule Artus.Repo.Migrations.AddManyToManyTags do
  use Ecto.Migration

  def change do
    create table(:entries_tags_things, primary_key: false) do
      add :entry_id, references(:entries)
      add :tag_id, references(:tags)
    end
    
    create table(:entries_tags_works, primary_key: false) do
      add :entry_id, references(:entries)
      add :tag_id, references(:tags)
    end
    
    alter table(:entries) do
      remove :subject_things
      remove :subject_works
    end
  end
end
