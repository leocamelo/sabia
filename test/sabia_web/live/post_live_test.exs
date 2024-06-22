defmodule SabiaWeb.PostLiveTest do
  use SabiaWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sabia.FeedFixtures

  @create_attrs %{body: "some body"}
  @invalid_attrs %{body: nil}

  defp create_post(%{user: user}) do
    %{post: post_fixture(user.id)}
  end

  describe "Index" do
    setup [:register_and_log_in_user, :create_post]

    test "lists all posts", %{conn: conn, post: post} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Feed"
      assert html =~ post.body
    end

    test "saves new post", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live
             |> form("#post-form", post: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#post-form", post: @create_attrs)
             |> render_submit()

      flash = assert_redirect(index_live, ~p"/")
      assert flash["info"] =~ "Fofoca created successfully"

      {:ok, _index_live, html} = live(conn, ~p"/")
      assert html =~ "some body"
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/fofoca/#{post}")

      assert html =~ post.body
    end

    test "deletes post", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/fofoca/#{post}")

      assert show_live |> element("a", "Delete") |> render_click()

      assert_redirect(show_live, ~p"/")

      {:ok, index_live, _html} = live(conn, ~p"/")
      refute has_element?(index_live, "#posts-#{post.id}")
    end
  end
end
