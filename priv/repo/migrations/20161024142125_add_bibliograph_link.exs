defmodule Artus.Repo.Migrations.AddBibliographLink do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :bibliograph, references(:users)
      add :bibliograph_id, :id
    end
  end
end
