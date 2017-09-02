defmodule Artus.Repo.Migrations.AddEntryParents do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :working_cache, :id
      add :parent, :id
    end
  end
end
