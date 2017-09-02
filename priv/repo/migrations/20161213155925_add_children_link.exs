defmodule Artus.Repo.Migrations.AddChildrenLink do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :children_parent_id, references(:entries)
    end
  end
end
