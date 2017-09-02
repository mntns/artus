defmodule Artus.Repo.Migrations.AddEntryLinkFields do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :review_parent_id, references(:entries)
      add :reprint_parent_id, references(:entries)
    end
  end
end
