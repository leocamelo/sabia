defmodule Sabia.Feed do
  @moduledoc """
  The Feed context.
  """

  import Ecto.Query, warn: false
  alias Sabia.Repo

  alias Sabia.Feed.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(from p in Post, order_by: [desc: p.inserted_at])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Repo.get!(Post, id)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(user_id, %{field: value})
      {:ok, %Post{}}

      iex> create_post(user_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(user_id, attrs \\ %{}) do
    %Post{user_id: user_id}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(user_id, post)
      {:ok, %Post{}}

  """
  def delete_post(user_id, %Post{id: id}) do
    {1, [post]} =
      from(p in Post, where: p.id == ^id and p.user_id == ^user_id, select: p)
      |> Repo.delete_all()

    {:ok, post}
  end

  @doc """
  Increments a post likes count.

  ## Examples

      iex> inc_post_likes(post)
      {:ok, %Post{}}

  """
  def inc_post_likes(%Post{id: id}) do
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [likes_count: 1])

    {:ok, post}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Preloads a post (or collection of posts) user association.

      iex> preload_post_user(post)
      %Post{user: %User{}}

  """
  def preload_post_user(post_or_posts) do
    Repo.preload(post_or_posts, :user)
  end

  @doc false
  def subscribe_to_posts(subtopic \\ "feed") do
    do_subscribe("posts:#{subtopic}")
  end

  @doc false
  def broadcast_post(%Post{id: id} = post, event) do
    do_broadcast("posts:feed", event, post)
    do_broadcast("posts:#{id}", event, post)
  end

  defp do_subscribe(topic) do
    Phoenix.PubSub.subscribe(Sabia.PubSub, topic)
  end

  defp do_broadcast(topic, event, post) do
    Phoenix.PubSub.broadcast(Sabia.PubSub, topic, {__MODULE__, {event, post}})
  end
end
