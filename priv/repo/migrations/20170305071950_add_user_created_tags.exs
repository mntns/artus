defmodule Artus.Repo.Migrations.AddUserCreatedTags do
  use Ecto.Migration

  def change do
    alter table(:tags) do
      add :user_tag, :boolean
    end

  end
end
