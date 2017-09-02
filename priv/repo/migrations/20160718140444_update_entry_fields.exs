defmodule Artus.Repo.Migrations.UpdateEntryFields do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      remove :titl_type

      add :part, :integer

      add :subject_things, {:array, :integer}
      add :subject_works, {:array, :integer}
      add :additional_info, :string
      add :links, :string
      add :internal_comment, :string
    end

  end
end
