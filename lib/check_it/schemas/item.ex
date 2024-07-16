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
    changeset = cast(%__MODULE__{}, params, [:description])

    changeset =
      if list do
        put_change(changeset, :list_id, list.id)
      else
        changeset
      end

    validate_required(changeset, [:list_id, :description])
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
