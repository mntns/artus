defmodule Artus.Repo.Migrations.AddUserActivatedField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :activated, :boolean
    end
  end
end
