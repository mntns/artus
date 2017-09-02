defmodule Artus.Repo.Migrations.RemoveRenderedTag do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      remove :rendered
    end

  end
end
