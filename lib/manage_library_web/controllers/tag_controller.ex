defmodule ManageLibraryWeb.TagController do
  use ManageLibraryWeb, :controller

  alias ManageLibrary.Library
  alias ManageLibrary.Library.Tag

  def index(conn, _params) do
    tags = Library.list_tags()
    render(conn, :index, tags: tags)
  end

  def new(conn, _params) do
    changeset = Library.change_tag(%Tag{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"tag" => tag_params}) do
    case Library.create_tag(tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Tag created successfully.")
        |> redirect(to: ~p"/tags/#{tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tag = Library.get_tag!(id)
    render(conn, :show, tag: tag)
  end

  def edit(conn, %{"id" => id}) do
    tag = Library.get_tag!(id)
    changeset = Library.change_tag(tag)
    render(conn, :edit, tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Library.get_tag!(id)

    case Library.update_tag(tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, "Tag updated successfully.")
        |> redirect(to: ~p"/tags/#{tag}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, tag: tag, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = Library.get_tag!(id)
    {:ok, _tag} = Library.delete_tag(tag)

    conn
    |> put_flash(:info, "Tag deleted successfully.")
    |> redirect(to: ~p"/tags")
  end
end
