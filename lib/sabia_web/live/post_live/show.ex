defmodule SabiaWeb.PostLive.Show do
  use SabiaWeb, :live_view

  alias Sabia.Feed
  alias Sabia.Feed.Post

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket), do: Feed.subscribe()

    post =
      Feed.get_post!(id)
      |> Feed.preload_post_user()

    {:ok,
     socket
     |> assign(:post, post)
     |> assign_current_author()
     |> assign_page_title()}
  end

  @impl true
  def handle_info({Feed, {:saved, post}}, socket) do
    {:noreply, assign(socket, :post, post)}
  end

  def handle_info({Feed, {:deleted, _post}}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Fofoca deleted by author")
     |> push_navigate(to: ~p"/", replace: true)}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    {:ok, post} = Feed.inc_post_likes(%Post{id: id})
    post = Feed.preload_post_user(post)

    Feed.broadcast(:saved, post)
    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, post} =
      socket.assigns.current_user.id
      |> Feed.delete_post(%Post{id: id})

    Feed.broadcast(:deleted, post)

    {:noreply,
     socket
     |> put_flash(:info, "Fofoca deleted successfully")
     |> push_navigate(to: ~p"/", replace: true)}
  end

  defp assign_current_author(socket) do
    if user = socket.assigns.current_user do
      assign(socket, :current_author, user.id == socket.assigns.post.user_id)
    else
      assign(socket, :current_author, false)
    end
  end

  defp assign_page_title(socket) do
    if socket.assigns.current_author do
      assign(socket, :page_title, "Your fofoca")
    else
      assign(socket, :page_title, "Fofoca")
    end
  end
end
