defmodule Artus.Repo.Migrations.ChangeEntryBranchType do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :branch
      add :branch, :integer
    end
  end

  def down do
  end
end
