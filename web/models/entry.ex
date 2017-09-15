defmodule Artus.Entry do
  use Artus.Web, :model

  schema "entries" do
    field :branch, :integer
    field :type, :string
    field :part, :integer

    field :submit_date, Ecto.DateTime
    field :submit_user, :integer
    field :public, :boolean

    field :biblio_record_id, :string
    field :author, :string
    field :editor, :string
    field :editor_primary_work, :string
    field :reviewer, :string
    field :titl_title, :string
    field :titl_subtitle, :string
    field :titl_add, :string
    field :ser_title, :string
    field :ser_volume, :integer
    field :ser_code, :string
    field :ser_issue, :integer
    field :ser_count, :string
    field :ser_year_pub, :integer
    field :publ_pub_house, :string
    field :publ_pub_place, :string
    field :biblio_issn, :string
    field :biblio_isbn, :string
    field :doi, :string
    field :abstract, :string
    field :language, :string

    field :additional_info, :string
    field :links, :string
    field :internal_comment, :string

    many_to_many :tags, Artus.Tag, join_through: "entries_tags", on_delete: :delete_all

    has_many :reviews, Artus.Entry, foreign_key: :review_parent_id
    has_many :reprints, Artus.Entry, foreign_key: :reprint_parent_id
    has_many :children, Artus.Entry, foreign_key: :children_parent_id
    belongs_to :review_parent, Artus.Entry, foreign_key: :review_parent_id
    belongs_to :reprint_parent, Artus.Entry, foreign_key: :reprint_parent_id
    belongs_to :children_parent, Artus.Entry, foreign_key: :children_parent_id, on_replace: :nilify

    field :system_type, :integer
    belongs_to :cache, Artus.Cache, on_replace: :nilify
    belongs_to :bibliograph, Artus.User, on_replace: :nilify

    belongs_to :user, Artus.User, on_replace: :nilify

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(biblio_record_id branch type part public author editor editor_primary_work reviewer
                       titl_title titl_subtitle titl_add ser_title ser_volume ser_code ser_year_pub 
                       publ_pub_house publ_pub_place biblio_issn biblio_isbn doi abstract language
                       ser_issue ser_count additional_info links internal_comment system_type))
                       #|> cast_assoc(:cache, required: false)
    #|> cast_assoc(:bibliograph, required: false)
    |> put_assoc(:user, params.user, required: true)
  end
  
  def changeset2(model, params \\ %{}) do
    model
    |> cast(params, ~w(biblio_record_id branch type part public author editor editor_primary_work reviewer
                       titl_title titl_subtitle titl_add ser_title ser_volume ser_code ser_year_pub 
                       publ_pub_house publ_pub_place biblio_issn biblio_isbn doi abstract language
                       ser_issue ser_count additional_info links internal_comment system_type))
  end

end
