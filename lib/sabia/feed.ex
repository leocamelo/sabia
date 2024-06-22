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

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
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

  def preload_post_user(posts_or_post) do
    Repo.preload(posts_or_post, :user)
  end
end
