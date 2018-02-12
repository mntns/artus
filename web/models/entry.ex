defmodule Artus.Entry do
  @moduledoc "Model for bibliographic entries"
  use Artus.Web, :model

  schema "entries" do
    # Type and part
    field :type, :string
    field :part, :integer

    # Metadata
    field :submit_date, :naive_datetime
    field :system_type, :integer
    field :public, :boolean

    # Form fields
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
    field :language, :string
    
    # Textbox form entries (text type!)
    field :abstract, :string
    field :internal_comment, :string
    field :additional_info, :string 
    field :links, :string

    # Tags
    many_to_many :tags, Artus.Tag, join_through: "entries_tags", on_delete: :delete_all

    # Associated entries (reviews, reprints, children)
    has_many :reviews, Artus.Entry, foreign_key: :review_parent_id
    has_many :reprints, Artus.Entry, foreign_key: :reprint_parent_id
    has_many :children, Artus.Entry, foreign_key: :children_parent_id
    belongs_to :review_parent, Artus.Entry, foreign_key: :review_parent_id
    belongs_to :reprint_parent, Artus.Entry, foreign_key: :reprint_parent_id
    belongs_to :children_parent, Artus.Entry, foreign_key: :children_parent_id, on_replace: :nilify

    # Ownerships (cache, bibliograph, user) 
    belongs_to :cache, Artus.Cache, on_replace: :nilify
    belongs_to :bibliograph, Artus.User, on_replace: :nilify
    belongs_to :user, Artus.User, on_replace: :nilify

    timestamps()
  end

  defp normalize_model(model) do
    Enum.map(model, fn({k,v}) -> 
      if (is_map(v)) do
        case k do
          "ser_code" -> {k, v["abbr"]}
          _ -> {k, v["value"]}
        end
      else
        {k,v}
      end
    end)
    |> Enum.into(%{})
  end

  def submit_changeset(model, user, cache, params \\ %{}) do
    fields = Artus.DefinitionManager.fields()
    params = params
             |> normalize_model()

    type = params["type"]
    type_fields = fields[type] |> Enum.reject(&Enum.member?(~w(subject_things subject_works), hd(&1))) 
    permitted = type_fields |> Enum.map(&hd(&1))
    permitted = permitted ++ ["type", "part"]
    required = type_fields 
               |> Enum.filter(fn(x) -> Enum.at(x, 1) == true end) 
               |> Enum.map(&hd(&1))
               |> Enum.map(&String.to_atom(&1))
               
    model
    |> cast(params, permitted)
    |> validate_required(required)
    |> put_change(:public, false)
    |> put_assoc(:cache, cache, required: true)
    |> put_assoc(:user, user, required: true)
    |> put_assoc(:bibliograph, user, required: true)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(biblio_record_id branch type part public author editor editor_primary_work reviewer
                       titl_title titl_subtitle titl_add ser_title ser_volume ser_code ser_year_pub 
                       publ_pub_house publ_pub_place biblio_issn biblio_isbn doi abstract language
                       ser_issue ser_count additional_info links internal_comment system_type))
    |> cast_assoc(:cache, required: false)
    |> cast_assoc(:user, required: true)
    |> cast_assoc(:bibliograph, required: true)
  end
end
