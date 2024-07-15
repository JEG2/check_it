defmodule CheckIt.Schemas.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :description, :string
    field :checked_at, :naive_datetime
    belongs_to :list, CheckIt.Schemas.List
    timestamps()
  end

  def create_changeset(list, params) do
    %__MODULE__{}
    |> cast(params, [:description])
    |> validate_required([:description])
    |> put_change(:list, list)
  end

  def toggle_changeset(item) do
    value =
      cond do
        is_nil(item.checked_at) ->
          NaiveDateTime.utc_now()
          |> NaiveDateTime.truncate(:second)

        true ->
          nil
      end

    change(item, checked_at: value)
  end
end
