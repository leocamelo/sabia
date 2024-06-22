defmodule SabiaWeb.PostLive.Show do
  use SabiaWeb, :live_view

  alias Sabia.Feed

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    post = Feed.get_post!(id) |> Feed.preload_post_user()

    {:ok,
     socket
     |> assign(:page_title, "Fofoca from #{post.user.username}")
     |> assign(:post, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    {:ok, _} = Feed.delete_post(%Feed.Post{id: id})

    {:noreply,
     socket
     |> put_flash(:info, "Fofoca deleted successfully")
     |> push_navigate(to: ~p"/", replace: true)}
  end
end
