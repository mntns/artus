defmodule Artus.Repo.Migrations.ChangeTextboxTypes do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      modify :abstract, :text
      modify :internal_comment, :text
      modify :additional_info, :text
      modify :links, :text
    end
  end
end
