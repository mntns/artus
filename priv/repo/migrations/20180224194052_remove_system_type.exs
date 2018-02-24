defmodule Artus.Repo.Migrations.RemoveSystemType do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :system_type
    end
  end
end
