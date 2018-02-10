defmodule Artus.Tag do
  @moduledoc "Model for bibliographic tags"
  use Artus.Web, :model

  schema "tags" do
    field :tag, :string
    field :type, :integer # 1: things, 2: authors/works
    field :user_tag, :boolean

    many_to_many :entries, Artus.Entry, join_through: "entries_tags", on_delete: :delete_all
    
    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:tag, :type, :user_tag])
    |> validate_required([:tag, :type, :user_tag])
    |> foreign_key_constraint(:entries_tags_tag_id_fkey)
  end
  
end

defimpl Poison.Encoder, for: Artus.Tag do
  def encode(model, opts) do
    model
    |> Map.take([:tag, :type, :id])
    |> Poison.Encoder.encode(opts)
  end
end
