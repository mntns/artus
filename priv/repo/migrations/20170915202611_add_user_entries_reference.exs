defmodule Artus.Repo.Migrations.AddUserEntriesReference do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :user_id, references(:users)
    end
  end
end
