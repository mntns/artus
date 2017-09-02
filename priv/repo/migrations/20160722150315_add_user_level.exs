defmodule Artus.Repo.Migrations.AddUserLevel do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :level, :integer
    end

  end
end
