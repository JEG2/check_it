defmodule CheckIt.Schemas.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    has_many :items, CheckIt.Schemas.Item, preload_order: [desc: :checked_at, desc: :updated_at]
    timestamps()
  end

  def changeset(list \\ %__MODULE__{}, params) do
    list
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
