defmodule ManageLibraryWeb.BookAuthorControllerTest do
  use ManageLibraryWeb.ConnCase

  import ManageLibrary.LibraryFixtures

  @create_attrs %{author_id: 42, book_id: 42}
  @update_attrs %{author_id: 43, book_id: 43}
  @invalid_attrs %{author_id: nil, book_id: nil}

  describe "index" do
    test "lists all book_authors", %{conn: conn} do
      conn = get(conn, ~p"/book_authors")
      assert html_response(conn, 200) =~ "Listing Book authors"
    end
  end

  describe "new book_author" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/book_authors/new")
      assert html_response(conn, 200) =~ "New Book author"
    end
  end

  describe "create book_author" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/book_authors", book_author: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/book_authors/#{id}"

      conn = get(conn, ~p"/book_authors/#{id}")
      assert html_response(conn, 200) =~ "Book author #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/book_authors", book_author: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Book author"
    end
  end

  describe "edit book_author" do
    setup [:create_book_author]

    test "renders form for editing chosen book_author", %{conn: conn, book_author: book_author} do
      conn = get(conn, ~p"/book_authors/#{book_author}/edit")
      assert html_response(conn, 200) =~ "Edit Book author"
    end
  end

  describe "update book_author" do
    setup [:create_book_author]

    test "redirects when data is valid", %{conn: conn, book_author: book_author} do
      conn = put(conn, ~p"/book_authors/#{book_author}", book_author: @update_attrs)
      assert redirected_to(conn) == ~p"/book_authors/#{book_author}"

      conn = get(conn, ~p"/book_authors/#{book_author}")
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, book_author: book_author} do
      conn = put(conn, ~p"/book_authors/#{book_author}", book_author: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Book author"
    end
  end

  describe "delete book_author" do
    setup [:create_book_author]

    test "deletes chosen book_author", %{conn: conn, book_author: book_author} do
      conn = delete(conn, ~p"/book_authors/#{book_author}")
      assert redirected_to(conn) == ~p"/book_authors"

      assert_error_sent 404, fn ->
        get(conn, ~p"/book_authors/#{book_author}")
      end
    end
  end

  defp create_book_author(_) do
    book_author = book_author_fixture()
    %{book_author: book_author}
  end
end
