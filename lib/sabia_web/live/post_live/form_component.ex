defmodule SabiaWeb.PostLive.FormComponent do
  use SabiaWeb, :live_component

  alias Sabia.Feed

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={@form[:body]}
          type="textarea"
          label="New fofoca"
          placeholder="What is happening?!"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Feed.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Feed.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case Feed.create_post(socket.assigns.post.user_id, post_params) do
      {:ok, post} ->
        send(self(), {__MODULE__, {:saved, post}})

        {:noreply,
         socket
         |> assign_form(Feed.change_post(socket.assigns.post))
         |> put_flash(:info, "Fofoca created successfully")
         |> push_patch(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
