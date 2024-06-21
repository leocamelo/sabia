defmodule SabiaWeb.PostLive.Show do
  use SabiaWeb, :live_view

  alias Sabia.Feed

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show post")
     |> assign(:post, Feed.get_post!(id))}
  end
end
