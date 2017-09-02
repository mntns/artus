defmodule Artus.Repo.Migrations.CreateEntry do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :biblio_record_id, :string
      add :branch, :string
      add :type, :string

      timestamps
    end

  end
end
