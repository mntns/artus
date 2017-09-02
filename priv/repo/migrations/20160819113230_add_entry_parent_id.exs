defmodule Artus.Repo.Migrations.AddEntryParentId do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :parent_id, references(:entries)
    end

  end
end
