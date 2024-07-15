defmodule CheckItWeb.Interface do
  use CheckItWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       lists: CheckIt.Lists.get_all() |> Enum.map(fn list -> {list.name, list.id} end),
       current_list: %CheckIt.Schemas.List{items: []},
       item_form: to_form(CheckIt.Items.new()),
       list_form: to_form(CheckIt.Lists.new())
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
        value={@current_list && @current_list.id}
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
          <.input field={@list_form[:name]} label="Name" autocomplete="off" />
          <:actions>
            <.button>Create List</.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>

    <.simple_form for={to_form(%{})}>
      <.input
        :for={item <- @current_list.items}
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

  def handle_event("manage_item_form", %{"item" => %{"list_id" => "create"}}, socket) do
    {:noreply,
     push_event(socket, "js-exec", %{
       to: "#server_commands",
       attr: "data-show-create-list"
     })}
  end

  def handle_event("manage_item_form", params, socket) do
    list = CheckIt.Lists.get_one(params["item"]["list_id"])

    {:noreply,
     assign(socket,
       current_list: list,
       item_form: to_form(CheckIt.Items.change(list, params["item"]))
     )}
  end

  def handle_event("manage_list_form", params, socket) do
    {:noreply, assign(socket, list_form: to_form(CheckIt.Lists.change(params["list"])))}
  end

  def handle_event("create_list", params, socket) do
    case CheckIt.Lists.create(params["list"]) do
      {:ok, list} ->
        {:noreply,
         socket
         |> assign(
           lists: [{list.name, list.id} | socket.assigns.lists],
           current_list: CheckIt.Lists.get_one(list.id),
           list_form: to_form(CheckIt.Lists.new())
         )
         |> push_event("js-exec", %{
           to: "#server_commands",
           attr: "data-hide-create-list"
         })}

      {:error, changeset} ->
        {:noreply, assign(socket, list_form: to_form(changeset))}
    end
  end

  def handle_event("add_item", params, socket) do
    case CheckIt.Items.create(socket.assigns.current_list, params["item"]) do
      {:ok, item} ->
        {:noreply,
         assign(socket,
           current_list: CheckIt.Lists.get_one(item.list_id),
           item_form: to_form(CheckIt.Items.new())
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, item_form: to_form(changeset))}
    end
  end

  def handle_event("check_item", params, socket) do
    id = params |> Map.fetch!("id") |> String.to_integer()

    item =
      Enum.find(socket.assigns.current_list.items, fn item ->
        item.id == id
      end)

    {:ok, _item} = CheckIt.Items.toggle(item)

    {:noreply,
     assign(socket,
       current_list: CheckIt.Lists.get_one(item.list_id)
     )}
  end
end
