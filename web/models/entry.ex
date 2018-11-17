defmodule Artus.Entry do
  @moduledoc "Model for bibliographic entries"
  use Artus.Web, :model

  schema "entries" do
    # Type and part
    field :type, :string
    field :part, :integer

    # Metadata
    field :submit_date, :naive_datetime
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
    has_many :reviews, Artus.Entry, foreign_key: :review_parent_id, on_delete: :delete_all
    has_many :reprints, Artus.Entry, foreign_key: :reprint_parent_id, on_delete: :delete_all
    has_many :children, Artus.Entry, foreign_key: :children_parent_id, on_delete: :delete_all
    belongs_to :review_parent, Artus.Entry, foreign_key: :review_parent_id
    belongs_to :reprint_parent, Artus.Entry, foreign_key: :reprint_parent_id
    belongs_to :children_parent, Artus.Entry, foreign_key: :children_parent_id, on_replace: :nilify

    # Ownerships (cache, user) 
    belongs_to :cache, Artus.Cache, on_replace: :nilify
    belongs_to :user, Artus.User, on_replace: :nilify
    
    field :bibliographer, :string
    field :last_change_user, :string

    timestamps()
  end

  defp normalize_model(model) do
    model
    |> Enum.map(fn({k, v}) -> 
      if is_map(v) do
        case k do
          "ser_code" -> {k, v["abbr"]}
          _ -> {k, v["value"]}
        end
    else
      {k, v}
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
    |> put_change(:last_change_user, user.name)
    |> put_assoc(:cache, cache, required: true)
    |> put_assoc(:user, user, required: true)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(bibliographer biblio_record_id type part public author editor editor_primary_work reviewer
                       titl_title titl_subtitle titl_add ser_title ser_volume ser_code ser_year_pub 
                       publ_pub_house publ_pub_place biblio_issn biblio_isbn doi abstract language
                       ser_issue ser_count additional_info links internal_comment))
    |> cast_assoc(:cache, required: false)
    |> cast_assoc(:user, required: true)
  end
  
  def publish_changeset(model) do
    # ~w(type part submit_date public biblio_record_id author editor editor_primary_work reviewer titl_title titl_subtitle titl_add ser_title ser_volume ser_code ser_issue ser_count ser_year_pub publ_pub_house publ_pub_place biblio_issn biblio_isbn doi language abstract internal_comment additional_info links bibliographer last_change_user))
    model
    |> cast(%{}, [])
    |> put_change(:public, true)
    |> put_assoc(:cache, nil)
  end
end
