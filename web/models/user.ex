defmodule Artus.User do
  @moduledoc "Model for bibliographers' accounts"
  use Artus.Web, :model

  schema "users" do
    field :name, :string
    field :hash, :string
    field :mail, :string
    field :branch, :integer
    field :admin, :boolean

    field :activated, :boolean
    field :activation_code, :string
    field :level, :integer

    has_many :caches, Artus.Cache, on_delete: :delete_all
    has_many :entries, Artus.Entry

    timestamps()
  end

  @doc "Builds default changeset"
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :hash, :mail, :branch, :admin, :activated, :activation_code, :level])
    |> validate_required([:name, :mail, :branch, :level])
    |> update_change(:mail, &String.downcase/1)
    |> unique_constraint(:mail)
  end
end
