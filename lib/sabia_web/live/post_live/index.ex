defmodule SabiaWeb.PostLive.Index do
  use SabiaWeb, :live_view

  alias Sabia.Feed
  alias Sabia.Feed.Post

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Feed")
     |> stream(:posts, Feed.list_posts())
     |> maybe_assign_post}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_info({SabiaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Feed.get_post!(id)
    {:ok, _} = Feed.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  defp maybe_assign_post(socket) do
    if user = socket.assigns.current_user do
      assign(socket, :post, %Post{user_id: user.id})
    else
      socket
    end
  end
end
