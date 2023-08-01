defmodule ManageLibrary.LibraryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ManageLibrary.Library` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> ManageLibrary.Library.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  @doc """
  Generate a book.
  """
  def book_fixture(attrs \\ %{}) do
    {:ok, book} =
      attrs
      |> Enum.into(%{
        description: "some description",
        dop: ~D[2023-05-06],
        isbn: 42,
        name: "some name"
      })
      |> ManageLibrary.Library.create_book()

    book
  end

  @doc """
  Generate a author.
  """
  def author_fixture(attrs \\ %{}) do
    {:ok, author} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ManageLibrary.Library.create_author()

    author
  end

  @doc """
  Generate a isbn.
  """
  def isbn_fixture(attrs \\ %{}) do
    {:ok, isbn} =
      attrs
      |> Enum.into(%{
        isbn: "some isbn"
      })
      |> ManageLibrary.Library.create_isbn()

    isbn
  end

  @doc """
  Generate a tag.
  """
  def tag_fixture(attrs \\ %{}) do
    {:ok, tag} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> ManageLibrary.Library.create_tag()

    tag
  end

  @doc """
  Generate a book_author.
  """
  def book_author_fixture(attrs \\ %{}) do
    {:ok, book_author} =
      attrs
      |> Enum.into(%{
        author_id: 42,
        book_id: 42
      })
      |> ManageLibrary.Library.create_book_author()

    book_author
  end

  @doc """
  Generate a book_tag.
  """
  def book_tag_fixture(attrs \\ %{}) do
    {:ok, book_tag} =
      attrs
      |> Enum.into(%{
        book_id: 42,
        tag_id: 42
      })
      |> ManageLibrary.Library.create_book_tag()

    book_tag
  end
end
