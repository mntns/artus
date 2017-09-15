@moduledoc "Model for working caches"
defmodule Artus.Cache do
  use Artus.Web, :model

  schema "caches" do
    field :name, :string

    belongs_to :user, Artus.User, on_replace: :nilify
    has_many :entries, Artus.Entry, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
    |> cast_assoc(:user, required: true)
  end
end
