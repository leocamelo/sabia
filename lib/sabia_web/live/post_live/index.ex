defmodule SabiaWeb.PostLive.Index do
  use SabiaWeb, :live_view

  alias Sabia.Feed
  alias Sabia.Feed.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Feed.subscribe()

    {:ok,
     socket
     |> assign(:page_title, "Feed")
     |> maybe_assign_new_post
     |> stream(:posts, Feed.list_posts() |> Feed.preload_post_user())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({SabiaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, broadcast_post(socket, post)}
  end

  def handle_info({Feed, {:saved, post}}, socket) do
    {:noreply, stream_post(socket, post)}
  end

  def handle_info({Feed, {:deleted, post}}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    post = Feed.inc_post_likes(%Post{id: id})
    {:noreply, broadcast_post(socket, post)}
  end

  defp broadcast_post(socket, post) do
    post = Feed.preload_post_user(post)
    Feed.broadcast(:saved, post)
    stream_post(socket, post)
  end

  defp stream_post(socket, post) do
    stream_insert(socket, :posts, post, at: 0)
  end

  defp maybe_assign_new_post(socket) do
    if user = socket.assigns.current_user do
      assign(socket, :new_post, %Post{user_id: user.id})
    else
      socket
    end
  end
end
