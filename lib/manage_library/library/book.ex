defmodule ManageLibrary.Library.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :book_authors_id, :integer
    field :description, :string
    field :dop, :date
    field :isbn_id, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :book_authors_id, :isbn_id, :description, :dop])
    |> validate_required([:name, :book_authors_id, :isbn_id, :description, :dop])
  end
end
