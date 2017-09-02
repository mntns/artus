defmodule Artus.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :pass, :string
      add :mail, :string

      timestamps
    end

  end
end
