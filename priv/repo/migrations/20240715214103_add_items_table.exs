defmodule CheckIt.Repo.Migrations.AddItemsTable do
  use Ecto.Migration

  def change do
    create table("items") do
      add :description, :string
      add :checked_at, :naive_datetime
      add :list_id, references("lists")
      timestamps()
    end
  end
end
