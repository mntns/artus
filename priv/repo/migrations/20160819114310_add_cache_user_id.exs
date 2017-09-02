defmodule Artus.Repo.Migrations.AddCacheUserId do
  use Ecto.Migration

  def change do
    alter table(:caches) do
      add :user_id, references(:users)
    end

  end
end
