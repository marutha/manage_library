defmodule ManageLibraryWeb.BookAuthorController do
  use ManageLibraryWeb, :controller

  alias ManageLibrary.Library
  alias ManageLibrary.Library.BookAuthor

  def index(conn, _params) do
    book_authors = Library.list_book_authors()
    render(conn, :index, book_authors: book_authors)
  end

  def new(conn, _params) do
    changeset = Library.change_book_author(%BookAuthor{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"book_author" => book_author_params}) do
    case Library.create_book_author(book_author_params) do
      {:ok, book_author} ->
        conn
        |> put_flash(:info, "Book author created successfully.")
        |> redirect(to: ~p"/book_authors/#{book_author}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book_author = Library.get_book_author!(id)
    render(conn, :show, book_author: book_author)
  end

  def edit(conn, %{"id" => id}) do
    book_author = Library.get_book_author!(id)
    changeset = Library.change_book_author(book_author)
    render(conn, :edit, book_author: book_author, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book_author" => book_author_params}) do
    book_author = Library.get_book_author!(id)

    case Library.update_book_author(book_author, book_author_params) do
      {:ok, book_author} ->
        conn
        |> put_flash(:info, "Book author updated successfully.")
        |> redirect(to: ~p"/book_authors/#{book_author}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, book_author: book_author, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book_author = Library.get_book_author!(id)
    {:ok, _book_author} = Library.delete_book_author(book_author)

    conn
    |> put_flash(:info, "Book author deleted successfully.")
    |> redirect(to: ~p"/book_authors")
  end
end
