defmodule Artus.Repo.Migrations.ChangeEntryTypeSystem do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :is_review
      add :system_type, :integer
    end

  end
end
