defmodule Artus.User do
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

    timestamps
  end

  @required_fields ~w(name hash mail branch admin activated)
  @optional_fields ~w(activation_code)

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :hash, :mail, :branch, :admin, :activated, :activation_code, :level])
    |> validate_required([:name, :mail, :branch, :level])
    |> update_change(:mail, &String.downcase/1)
    |> unique_constraint(:mail)
  end
end
