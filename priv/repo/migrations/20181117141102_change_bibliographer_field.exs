defmodule Artus.Repo.Migrations.ChangeBibliographerField do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :bibliograph
      add :bibliographer, :string
      add :last_change_user, :string
    end
  end
end
