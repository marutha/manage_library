defmodule ManageLibrary.Library.BookTag do
  use Ecto.Schema
  import Ecto.Changeset

  alias ManageLibrary.Library.{Book, Tag}
  schema "book_tags" do
    belongs_to :book, Book
    belongs_to :tag, Tag
    timestamps()
  end

  @doc false
  def changeset(book_tag, attrs) do
    book_tag
    |> cast(attrs, [:book_id, :tag_id])
    |> validate_required([:book_id, :tag_id])
  end
end
