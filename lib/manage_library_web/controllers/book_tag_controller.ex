defmodule ManageLibraryWeb.BookTagController do
  use ManageLibraryWeb, :controller

  alias ManageLibrary.Library
  alias ManageLibrary.Library.BookTag

  def index(conn, _params) do
    book_tags = Library.list_book_tags()
    render(conn, :index, book_tags: book_tags)
  end

  def new(conn, _params) do
    changeset = Library.change_book_tag(%BookTag{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"book_tag" => book_tag_params}) do
    case Library.create_book_tag(book_tag_params) do
      {:ok, book_tag} ->
        conn
        |> put_flash(:info, "Book tag created successfully.")
        |> redirect(to: ~p"/book_tags/#{book_tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    book_tag = Library.get_book_tag!(id)
    render(conn, :show, book_tag: book_tag)
  end

  def edit(conn, %{"id" => id}) do
    book_tag = Library.get_book_tag!(id)
    changeset = Library.change_book_tag(book_tag)
    render(conn, :edit, book_tag: book_tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "book_tag" => book_tag_params}) do
    book_tag = Library.get_book_tag!(id)

    case Library.update_book_tag(book_tag, book_tag_params) do
      {:ok, book_tag} ->
        conn
        |> put_flash(:info, "Book tag updated successfully.")
        |> redirect(to: ~p"/book_tags/#{book_tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, book_tag: book_tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    book_tag = Library.get_book_tag!(id)
    {:ok, _book_tag} = Library.delete_book_tag(book_tag)

    conn
    |> put_flash(:info, "Book tag deleted successfully.")
    |> redirect(to: ~p"/book_tags")
  end
end
