defmodule CheckIt.Lists do
  def new(params \\ %{}) do
    [%{"name" => params["name"] || ""}, [as: :list]]
  end

  def create(params) do
    if is_binary(params["name"]) and String.length(params["name"]) > 0 do
      case :ets.match(:lists, {:_, params["name"], :"$1"}) do
        [[list]] when is_map(list) ->
          {:ok, get_one(list.id)}

        _no_match ->
          now = NaiveDateTime.utc_now()

          list = %{
            id: System.unique_integer([:positive, :monotonic]),
            name: params["name"],
            inserted_at: now,
            updated_at: now,
            items: []
          }

          :ets.insert(:lists, {list.id, list.name, list})
          {:ok, list}
      end
    else
      {:error, [params, [errors: [name: {"can't be blank", []}]]]}
    end
  end

  def get_all() do
    :ets.tab2list(:lists)
    |> Enum.map(fn {_id, _name, list} -> list end)
  end

  def get_one(id) do
    if is_nil(id) do
      nil
    else
      id =
        case id do
          i when is_binary(i) -> String.to_integer(i)
          i when is_integer(i) -> i
        end

      [{^id, _name, list}] = :ets.lookup(:lists, id)

      items =
        :ets.match(:items, {:_, id, :"$1"})
        |> List.flatten()
        |> Enum.sort_by(fn item -> [!is_nil(item.checked_at)] end)

      %{list | items: items}
    end
  end
end
