defmodule ManageLibrary.Library.BookAuthor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "book_authors" do
    field :author_id, :integer
    field :book_id, :integer

    timestamps()
  end

  @doc false
  def changeset(book_author, attrs) do
    book_author
    |> cast(attrs, [:book_id, :author_id])
    |> validate_required([:book_id, :author_id])
  end
end
