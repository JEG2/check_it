defmodule CheckIt.Lists do
  alias CheckIt.Schemas.List
  alias CheckIt.Repo

  def new(params \\ %{}) do
    List.changeset(params)
  end

  def create(params) do
    existing = Repo.get_by(List, name: Map.get(params, "name", ""))

    if existing do
      {:ok, existing}
    else
      params
      |> new()
      |> Repo.insert()
    end
  end

  def get_all() do
    Repo.all(List)
  end

  def get_one(id) do
    Repo.get(List, id)
    |> Repo.preload(:items)
  end
end
