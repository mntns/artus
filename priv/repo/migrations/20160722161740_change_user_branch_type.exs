defmodule Artus.Repo.Migrations.ChangeUserBranchType do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :branch
      add :branch, :integer
    end

  end
end
