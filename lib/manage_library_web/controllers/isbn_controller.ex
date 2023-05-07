defmodule ManageLibraryWeb.ISBNController do
  use ManageLibraryWeb, :controller

  alias ManageLibrary.Library
  alias ManageLibrary.Library.ISBN

  def index(conn, _params) do
    isbns = Library.list_isbns()
    render(conn, :index, isbns: isbns)
  end

  def new(conn, _params) do
    changeset = Library.change_isbn(%ISBN{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"isbn" => isbn_params}) do
    case Library.create_isbn(isbn_params) do
      {:ok, isbn} ->
        conn
        |> put_flash(:info, "Isbn created successfully.")
        |> redirect(to: ~p"/isbns/#{isbn}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    isbn = Library.get_isbn!(id)
    render(conn, :show, isbn: isbn)
  end

  def edit(conn, %{"id" => id}) do
    isbn = Library.get_isbn!(id)
    changeset = Library.change_isbn(isbn)
    render(conn, :edit, isbn: isbn, changeset: changeset)
  end

  def update(conn, %{"id" => id, "isbn" => isbn_params}) do
    isbn = Library.get_isbn!(id)

    case Library.update_isbn(isbn, isbn_params) do
      {:ok, isbn} ->
        conn
        |> put_flash(:info, "Isbn updated successfully.")
        |> redirect(to: ~p"/isbns/#{isbn}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, isbn: isbn, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    isbn = Library.get_isbn!(id)
    {:ok, _isbn} = Library.delete_isbn(isbn)

    conn
    |> put_flash(:info, "Isbn deleted successfully.")
    |> redirect(to: ~p"/isbns")
  end
end
