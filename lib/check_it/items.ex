defmodule CheckIt.Items do
  alias CheckIt.Schemas.Item
  alias CheckIt.Repo

  def new do
    Item.create_changeset(nil, %{})
  end

  def change(list, params) do
    Item.create_changeset(list, params)
  end

  def create(list, params) do
    list
    |> change(params)
    |> Repo.insert()
  end

  def toggle(item) do
    item
    |> Item.toggle_changeset()
    |> Repo.update()
  end
end
