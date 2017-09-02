defmodule Artus.Repo.Migrations.AddTagType do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :type, :integer
    end
  end
end
