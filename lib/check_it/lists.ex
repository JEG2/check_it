defmodule CheckIt.Lists do
  alias CheckIt.Schemas.List
  alias CheckIt.Repo

  def new do
    List.changeset(%{})
  end

  def change(params) do
    List.changeset(params)
  end

  def create(params) do
    params
    |> change()
    |> Repo.insert()
  end

  def get_all() do
    Repo.all(List)
  end

  def get_one(id) do
    Repo.get(List, id)
    |> Repo.preload(:items)
  end
end
