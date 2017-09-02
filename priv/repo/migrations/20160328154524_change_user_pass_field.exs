defmodule Artus.Repo.Migrations.ChangeUserPassField do
  use Ecto.Migration

  def change do
    rename table(:users), :pass, to: :hash
  end
end
