defmodule Artus.Repo.Migrations.CreateQuery do
  use Ecto.Migration

  def change do
    create table(:queries) do
      add :uuid, :string
      add :request, :text
      add :created_at, :datetime
      add :views, :integer

      timestamps()
    end

  end
end
