defmodule Artus.Repo.Migrations.AddUserActivationCodeField do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :activation_code, :string
    end
  end
end
