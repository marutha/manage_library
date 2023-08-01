defmodule ManageLibrary.Library.BookAuthor do
  use Ecto.Schema
  import Ecto.Changeset

  alias ManageLibrary.Library.{Book, Author}

  schema "book_authors" do
    belongs_to(:book, Book)
    belongs_to(:author, Author)

    timestamps()
  end

  @doc false
  def changeset(book_author, attrs) do
    book_author
    |> cast(attrs, [:book_id, :author_id])
    |> validate_required([:book_id, :author_id])
  end
end
