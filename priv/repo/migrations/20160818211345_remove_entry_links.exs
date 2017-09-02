defmodule Artus.Repo.Migrations.RemoveEntryLinks do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :reviews
      remove :reprints
    end
  end
end
