defmodule SabiaWeb.PostLive.Index do
  use SabiaWeb, :live_view

  alias Sabia.Feed
  alias Sabia.Feed.Post
  alias SabiaWeb.Endpoint

  @topic "feed"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Endpoint.subscribe(@topic)
    {:ok, stream(socket, :posts, Feed.list_posts() |> Feed.preload_post_user())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Feed")
     |> maybe_assign_post}
  end

  @impl true
  def handle_info({SabiaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    post = Feed.preload_post_user(post)
    Endpoint.broadcast(@topic, "new_post", post)
    {:noreply, stream_new_post(socket, post)}
  end

  def handle_info(%{event: "new_post", payload: post}, socket) do
    {:noreply, stream_new_post(socket, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Feed.get_post!(id)
    {:ok, _} = Feed.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  defp stream_new_post(socket, post) do
    stream_insert(socket, :posts, post, at: 0)
  end

  defp maybe_assign_post(socket) do
    if user = socket.assigns.current_user do
      assign(socket, :post, %Post{user_id: user.id})
    else
      socket
    end
  end
end
