defmodule ManageLibrary.Library.Book do
  use Ecto.Schema
  import Ecto.Changeset

  alias ManageLibrary.Library.{BookAuthor, BookTag}

  schema "books" do
    field :description, :string
    field :dop, :date
    field :isbn, :integer
    field :name, :string

    has_many(:authors, {"book_authors", BookAuthor}, foreign_key: :book_id)
    has_many(:tags, {"book_tags", BookTag}, foreign_key: :book_id)
    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :isbn, :description, :dop])
    |> validate_required([:name, :isbn, :description, :dop])
  end
end
