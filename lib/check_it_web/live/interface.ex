defmodule CheckItWeb.Interface do
  use CheckItWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       lists: [],
       current_list: "",
       items: %{},
       current_items: [],
       item_form: to_form(%{"list_id" => "", "description" => ""}),
       list_form: to_form(%{"name" => ""})
     )}
  end

  def render(assigns) do
    ~H"""
    <h1>Check It</h1>

    <.simple_form for={@item_form} phx-change="manage_item_form" phx-submit="add_item">
      <.input
        field={@item_form[:list_id]}
        type="select"
        prompt="Choose a list"
        options={@lists ++ [{"Create a new list", "create"}]}
        value={@current_list}
        label="List"
      />
      <.input field={@item_form[:description]} label="Item" />
      <:actions>
        <.button>Add Item</.button>
      </:actions>
    </.simple_form>

    <div
      id="server_commands"
      data-show-create-list={show_modal("create_list")}
      data-hide-create-list={hide_modal("create_list")}
    >
      <.modal id="create_list">
        <h2>Create A New List</h2>

        <.simple_form for={@list_form} phx-change="manage_list_form" phx-submit="create_list">
          <.input field={@list_form[:name]} label="Name" />
          <:actions>
            <.button>Create List</.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>

    <.simple_form for={to_form(%{})}>
      <.input
        :for={item <- @current_items}
        type="checkbox"
        name={"item_#{item.list_id}_#{item.id}"}
        value={!!item.checked_at}
        label={item.description}
        phx-click="check_item"
        phx-value-id={item.id}
      />
    </.simple_form>
    """
  end

  def handle_event("manage_item_form", %{"list_id" => "create"}, socket) do
    {:noreply,
     push_event(socket, "js-exec", %{
       to: "#server_commands",
       attr: "data-show-create-list"
     })}
  end

  def handle_event("manage_item_form", %{"list_id" => list_id} = params, socket) do
    {:noreply,
     assign(socket,
       current_list: list_id,
       item_form: to_form(params),
       current_items: Map.get(socket.assigns.items, list_id, [])
     )}
  end

  def handle_event("manage_list_form", params, socket) do
    {:noreply, assign(socket, list_form: to_form(params))}
  end

  def handle_event("create_list", %{"name" => name}, socket) do
    list = {name, System.unique_integer([:positive, :monotonic])}
    list_id = elem(list, 1)

    {:noreply,
     socket
     |> assign(
       lists: [list | socket.assigns.lists],
       current_list: list_id,
       current_items: Map.get(socket.assigns.items, list_id, []),
       list_form: to_form(%{"name" => ""})
     )
     |> push_event("js-exec", %{
       to: "#server_commands",
       attr: "data-hide-create-list"
     })}
  end

  def handle_event("add_item", %{"list_id" => list_id, "description" => description}, socket) do
    item = %{
      id: System.unique_integer([:positive, :monotonic]),
      list_id: list_id,
      description: description,
      inserted_at: DateTime.utc_now(),
      checked_at: nil
    }

    items = Map.update(socket.assigns.items, list_id, [item], fn items -> [item | items] end)

    {:noreply,
     assign(socket,
       items: items,
       current_items: Map.fetch!(items, socket.assigns.current_list),
       item_form: to_form(%{"list_id" => "", "description" => ""})
     )}
  end

  def handle_event("check_item", params, socket) do
    id = params |> Map.fetch!("id") |> String.to_integer()

    i =
      Enum.find_index(socket.assigns.current_items, fn item ->
        item.id == id
      end)

    item = Enum.at(socket.assigns.current_items, i)

    item =
      if params["value"] == "true" do
        %{item | checked_at: DateTime.utc_now()}
      else
        %{item | checked_at: nil}
      end

    items =
      put_in(
        socket.assigns.items,
        [socket.assigns.current_list, Access.at!(i)],
        item
      )

    {:noreply,
     assign(socket,
       items: items,
       current_items: Map.fetch!(items, socket.assigns.current_list)
     )}
  end
end
