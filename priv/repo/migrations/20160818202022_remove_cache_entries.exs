defmodule Artus.Repo.Migrations.RemoveCacheEntries do
  use Ecto.Migration

  def change do
    alter table(:caches) do
      remove :entries
    end
  end
end
