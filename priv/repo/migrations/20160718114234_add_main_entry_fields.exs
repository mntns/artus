defmodule Artus.Repo.Migrations.AddMainEntryFields do
  use Ecto.Migration

  def change do
    alter table(:entries) do
      add :submit_date, :datetime
      add :submit_user, :integer

      add :public, :boolean

      add :titl_type, :string
      add :author, :string
      add :editor, :string
      add :titl_title, :string
      add :titl_subtitle, :string
      add :titl_add, :string
      add :ser_title, :string
      add :ser_volume, :integer
      add :ser_code, :string
      add :ser_year_pub, :integer
      add :publ_pub_house, :string
      add :publ_pub_place, :string
      add :biblio_issn, :string
      add :biblio_isbn, :string
      add :doi, :string
      add :abstract, :string
      add :language, :string
    end
  end
end
