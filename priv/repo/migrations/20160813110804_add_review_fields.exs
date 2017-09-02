defmodule Artus.Repo.Migrations.AddReviewFields do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :reviewer, :string
      add :is_review, :boolean
    end
  end
end
