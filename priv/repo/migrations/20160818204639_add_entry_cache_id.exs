defmodule Artus.Repo.Migrations.AddEntryCacheId do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :working_cache
      remove :parent

      add :cache_id, :id
    end
  end
end
