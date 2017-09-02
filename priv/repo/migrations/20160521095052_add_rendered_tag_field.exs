defmodule Artus.Repo.Migrations.AddRenderedTagField do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :rendered, :string
    end
  end
end
