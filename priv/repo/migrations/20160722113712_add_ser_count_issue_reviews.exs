defmodule Artus.Repo.Migrations.AddSerCountIssueReviews do
  use Ecto.Migration

  def change do
    alter table(:entries) do

      add :ser_issue, :integer
      add :ser_count, :string

      add :reviews, {:array, :integer}
    end
  end
end
