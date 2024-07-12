defmodule CheckIt.Schemas.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :name, :string
    timestamps()
  end

  def changeset(list \\ %__MODULE__{}, params) do
    list
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
