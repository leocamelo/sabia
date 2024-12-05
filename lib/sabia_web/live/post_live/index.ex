defmodule SabiaWeb.PostLive.Index do
  use SabiaWeb, :live_view

  alias Sabia.Feed
  alias Sabia.Feed.Post

  @impl true
  def render(assigns) do
    ~H"""
    <.header class="text-center">
      {@page_title}
      <:subtitle>Get in touch about all the fofocas</:subtitle>
    </.header>

    <div class="space-y-12 divide-y">
      <div :if={@current_user}>
        <.live_component module={SabiaWeb.PostLive.FormComponent} id="new-post" post={@new_post} />
      </div>
      <div id="posts" phx-update="stream" class="pt-10 grid gap-4">
        <div :for={{dom_id, post} <- @streams.posts} id={dom_id}>
          <SabiaWeb.PostLive.PostComponent.post post={post} />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Feed.subscribe_to_posts()

    posts =
      Feed.list_posts()
      |> Feed.preload_post_user()

    {:ok,
     socket
     |> assign(:page_title, "Feed")
     |> maybe_assign_new_post()
     |> stream(:posts, posts)}
  end

  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_info({SabiaWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    post = %{post | user: socket.assigns.current_user}

    Feed.broadcast_post(post, :saved)
    {:noreply, stream_post(socket, post)}
  end

  def handle_info({Feed, {:saved, post}}, socket) do
    {:noreply, stream_post(socket, post)}
  end

  def handle_info({Feed, {:deleted, post}}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("like", %{"id" => id}, socket) do
    {:ok, post} = Feed.inc_post_likes(%Post{id: id})
    post = Feed.preload_post_user(post)

    Feed.broadcast_post(post, :saved)
    {:noreply, stream_post(socket, post)}
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
