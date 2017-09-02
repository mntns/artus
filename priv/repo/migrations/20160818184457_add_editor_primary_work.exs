defmodule Artus.Repo.Migrations.AddEditorPrimaryWork do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :editor_primary_work, :string
    end
  end
end
