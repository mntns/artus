defmodule Artus.Repo.Migrations.AddUserBranchField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :branch, :string
    end
  end
end
