defmodule Artus.Repo.Migrations.CreateAbbreviation do
  use Ecto.Migration

  def change do
    create table(:abbreviations) do
      add :abbr, :string
      add :title, :string
      add :place, :string
      add :publisher, :string
      add :issn, :string

      timestamps
    end

  end
end
