defmodule CheckIt.Items do
  def new(list, params \\ %{}) do
    [
      %{"list_id" => (list && list.id) || "", "description" => params["description"] || ""},
      [as: :item]
    ]
  end

  def create(list, params) do
    if is_map(list) and is_binary(params["description"]) and
         String.length(params["description"]) > 0 do
      now = NaiveDateTime.utc_now()

      item = %{
        id: System.unique_integer([:positive, :monotonic]),
        list_id: list.id,
        description: params["description"],
        checked_at: nil,
        inserted_at: now,
        updated_at: now
      }

      :ets.insert(:items, {item.id, item.list_id, item})
      {:ok, item}
    else
      errors = []

      errors =
        if is_map(list) do
          errors
        else
          [{:list_id, {"can't be blank", []}} | errors]
        end

      errors =
        if is_binary(params["description"]) and String.length(params["description"]) > 0 do
          errors
        else
          [{:description, {"can't be blank", []}} | errors]
        end

      {:error, [params, [errors: errors]]}
    end
  end

  def toggle(item) do
    value =
      cond do
        is_nil(item.checked_at) ->
          NaiveDateTime.utc_now()
          |> NaiveDateTime.truncate(:second)

        true ->
          nil
      end

    item = %{item | checked_at: value}
    :ets.insert(:items, {item.id, item.list_id, item})
    {:ok, item}
  end
end
