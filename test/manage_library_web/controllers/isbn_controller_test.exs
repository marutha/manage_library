defmodule ManageLibraryWeb.ISBNControllerTest do
  use ManageLibraryWeb.ConnCase

  import ManageLibrary.LibraryFixtures

  @create_attrs %{isbn: "some isbn"}
  @update_attrs %{isbn: "some updated isbn"}
  @invalid_attrs %{isbn: nil}

  describe "index" do
    test "lists all isbns", %{conn: conn} do
      conn = get(conn, ~p"/isbns")
      assert html_response(conn, 200) =~ "Listing Isbns"
    end
  end

  describe "new isbn" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/isbns/new")
      assert html_response(conn, 200) =~ "New Isbn"
    end
  end

  describe "create isbn" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/isbns", isbn: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/isbns/#{id}"

      conn = get(conn, ~p"/isbns/#{id}")
      assert html_response(conn, 200) =~ "Isbn #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/isbns", isbn: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Isbn"
    end
  end

  describe "edit isbn" do
    setup [:create_isbn]

    test "renders form for editing chosen isbn", %{conn: conn, isbn: isbn} do
      conn = get(conn, ~p"/isbns/#{isbn}/edit")
      assert html_response(conn, 200) =~ "Edit Isbn"
    end
  end

  describe "update isbn" do
    setup [:create_isbn]

    test "redirects when data is valid", %{conn: conn, isbn: isbn} do
      conn = put(conn, ~p"/isbns/#{isbn}", isbn: @update_attrs)
      assert redirected_to(conn) == ~p"/isbns/#{isbn}"

      conn = get(conn, ~p"/isbns/#{isbn}")
      assert html_response(conn, 200) =~ "some updated isbn"
    end

    test "renders errors when data is invalid", %{conn: conn, isbn: isbn} do
      conn = put(conn, ~p"/isbns/#{isbn}", isbn: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Isbn"
    end
  end

  describe "delete isbn" do
    setup [:create_isbn]

    test "deletes chosen isbn", %{conn: conn, isbn: isbn} do
      conn = delete(conn, ~p"/isbns/#{isbn}")
      assert redirected_to(conn) == ~p"/isbns"

      assert_error_sent 404, fn ->
        get(conn, ~p"/isbns/#{isbn}")
      end
    end
  end

  defp create_isbn(_) do
    isbn = isbn_fixture()
    %{isbn: isbn}
  end
end
