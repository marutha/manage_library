defmodule ManageLibraryWeb.BookTagControllerTest do
  use ManageLibraryWeb.ConnCase

  import ManageLibrary.LibraryFixtures

  @create_attrs %{book_id: 42, tag_id: 42}
  @update_attrs %{book_id: 43, tag_id: 43}
  @invalid_attrs %{book_id: nil, tag_id: nil}

  describe "index" do
    test "lists all book_tags", %{conn: conn} do
      conn = get(conn, ~p"/book_tags")
      assert html_response(conn, 200) =~ "Listing Book tags"
    end
  end

  describe "new book_tag" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/book_tags/new")
      assert html_response(conn, 200) =~ "New Book tag"
    end
  end

  describe "create book_tag" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/book_tags", book_tag: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/book_tags/#{id}"

      conn = get(conn, ~p"/book_tags/#{id}")
      assert html_response(conn, 200) =~ "Book tag #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/book_tags", book_tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Book tag"
    end
  end

  describe "edit book_tag" do
    setup [:create_book_tag]

    test "renders form for editing chosen book_tag", %{conn: conn, book_tag: book_tag} do
      conn = get(conn, ~p"/book_tags/#{book_tag}/edit")
      assert html_response(conn, 200) =~ "Edit Book tag"
    end
  end

  describe "update book_tag" do
    setup [:create_book_tag]

    test "redirects when data is valid", %{conn: conn, book_tag: book_tag} do
      conn = put(conn, ~p"/book_tags/#{book_tag}", book_tag: @update_attrs)
      assert redirected_to(conn) == ~p"/book_tags/#{book_tag}"

      conn = get(conn, ~p"/book_tags/#{book_tag}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, book_tag: book_tag} do
      conn = put(conn, ~p"/book_tags/#{book_tag}", book_tag: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Book tag"
    end
  end

  describe "delete book_tag" do
    setup [:create_book_tag]

    test "deletes chosen book_tag", %{conn: conn, book_tag: book_tag} do
      conn = delete(conn, ~p"/book_tags/#{book_tag}")
      assert redirected_to(conn) == ~p"/book_tags"

      assert_error_sent 404, fn ->
        get(conn, ~p"/book_tags/#{book_tag}")
      end
    end
  end

  defp create_book_tag(_) do
    book_tag = book_tag_fixture()
    %{book_tag: book_tag}
  end
end
