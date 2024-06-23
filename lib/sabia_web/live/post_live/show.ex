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
     |> assign(:page_title, "Fofoca from #{post.user.username}")
     |> assign(:post, post)}
  end

  @impl true
  def handle_info({Feed, {:saved, post}}, socket) do
    {:noreply, assign(socket, :post, post)}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    post =
      Feed.inc_post_likes(%Post{id: id})
      |> Feed.preload_post_user()

    Feed.broadcast(:saved, post)
    {:noreply, assign(socket, :post, post)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, post} = Feed.delete_post(%Post{id: id})
    Feed.broadcast(:deleted, post)

    {:noreply,
     socket
     |> put_flash(:info, "Fofoca deleted successfully")
     |> push_navigate(to: ~p"/", replace: true)}
  end
end
