defmodule Artus.Repo.Migrations.RemoveBranchAndSubmitUser do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :branch
      remove :submit_user
    end

  end
end
