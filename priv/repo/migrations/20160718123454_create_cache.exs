defmodule Artus.Repo.Migrations.CreateCache do
  use Ecto.Migration

  def change do
    create table(:caches) do
      add :name, :string
      add :user, :integer
      add :entries, {:array, :integer}

      timestamps()
    end

  end
end
