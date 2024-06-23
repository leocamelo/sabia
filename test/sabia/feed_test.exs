defmodule Sabia.FeedTest do
  use Sabia.DataCase

  alias Sabia.Feed

  describe "posts" do
    alias Sabia.Feed.Post

    import Sabia.{AccountsFixtures, FeedFixtures}

    @invalid_attrs %{body: nil}

    test "list_posts/0 returns all posts" do
      user = user_fixture()
      post = post_fixture(user.id)
      assert Feed.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(user.id)
      assert Feed.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()
      valid_attrs = %{body: "some body"}
      assert {:ok, %Post{} = post} = Feed.create_post(user.id, valid_attrs)
      assert post.body == "some body"
    end

    test "create_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Feed.create_post(user.id, @invalid_attrs)
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(user.id)
      assert {:ok, %Post{}} = Feed.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Feed.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(user.id)
      assert %Ecto.Changeset{} = Feed.change_post(post)
    end

    test "inc_post_likes/1 increments post likes count" do
      user = user_fixture()
      post1 = post_fixture(user.id)
      post2 = Feed.inc_post_likes(post1)
      assert_in_delta(post1.likes_count, post2.likes_count, 1)
    end
  end
end
