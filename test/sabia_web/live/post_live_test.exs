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

      assert_patch(index_live, ~p"/")

      html = render(index_live)
      assert html =~ "Fofoca created successfully"
      assert html =~ "some body"
    end

    test "likes a post", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      like_button =
        index_live
        |> element("#posts-#{post.id} button[title=\"Like\"]")

      assert render(like_button) =~ ~r{>\s*0\s*</button>}
      assert render_click(like_button) =~ ~r{>\s*1\s*</button>}
    end
  end

  describe "Show" do
    setup [:register_and_log_in_user, :create_post]

    test "displays post", %{conn: conn, post: post} do
      {:ok, _show_live, html} = live(conn, ~p"/fofoca/#{post}")

      assert html =~ post.body
    end

    test "likes a post", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/fofoca/#{post}")

      like_button =
        show_live
        |> element("button[title=\"Like\"]")

      assert render(like_button) =~ ~r{>\s*0\s*</button>}
      assert render_click(like_button) =~ ~r{>\s*1\s*</button>}
    end

    test "deletes post", %{conn: conn, post: post} do
      {:ok, show_live, _html} = live(conn, ~p"/fofoca/#{post}")

      assert show_live |> element("button[title=\"Delete\"]") |> render_click()

      assert_redirect(show_live, ~p"/")

      {:ok, index_live, _html} = live(conn, ~p"/")
      refute has_element?(index_live, "#posts-#{post.id}")
    end
  end
end
