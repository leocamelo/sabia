defmodule Sabia.FeedFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sabia.Feed` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(user_id, attrs \\ %{}) do
    attrs = Enum.into(attrs, %{body: "some body"})
    {:ok, post} = Sabia.Feed.create_post(user_id, attrs)
    post
  end
end
