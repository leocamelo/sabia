defmodule SabiaWeb.PostLive.PostComponent do
  use SabiaWeb, :html

  attr :post, Sabia.Feed.Post, required: true
  attr :deletable, :boolean, default: false
  attr :linkable, :boolean, default: true

  def post(assigns) do
    ~H"""
    <div class="group relative rounded-lg p-4 pb-2 mb-3 border border-zinc-100">
      <div class="flex flex-row">
        <div class="mr-4">
          <.gravatar email={@post.user.email} alt={@post.user.username} />
        </div>
        <div>
          <h5 class="mb-2 font-medium leading-tight text-zinc-700">
            @<%= @post.user.username %>
          </h5>
          <p class="text-base text-zinc-900">
            <%= @post.body %>
          </p>
        </div>
      </div>
      <div class="flex flex-row justify-between pt-2 mt-3">
        <button
          title="Like"
          phx-click="like"
          phx-value-id={@post.id}
          class="text-zinc-500 px-2 py-1 rounded-lg hover:text-rose-700 hover:bg-rose-100"
        >
          <.icon name="hero-heart" class="h-5 w-5" />
          <%= @post.likes_count %>
        </button>
        <button
          :if={@deletable}
          title="Delete"
          phx-click="delete"
          phx-value-id={@post.id}
          data-confirm="Are you sure?"
          class="hidden group-hover:block text-red-500 px-2 py-1 rounded-lg hover:text-red-700 hover:bg-red-100"
        >
          <.icon name="hero-trash" class="h-5 w-5" />
        </button>
      </div>
      <.link
        :if={@linkable}
        title="Link"
        href={~p"/fofoca/#{@post}"}
        class="hidden group-hover:block absolute top-2 right-2 text-zinc-400 hover:text-brand"
      >
        <.icon name="hero-link-mini" />
      </.link>
    </div>
    """
  end
end