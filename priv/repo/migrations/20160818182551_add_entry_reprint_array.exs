defmodule Artus.Repo.Migrations.AddEntryReprintArray do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :reprints, {:array, :integer}
    end
  end
end
