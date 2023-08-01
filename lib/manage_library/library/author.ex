defmodule ManageLibrary.Library.Author do
  use Ecto.Schema
  import Ecto.Changeset
  alias ManageLibrary.Library.{BookAuthor}

  schema "authors" do
    field :name, :string

    has_many(:books, {"book_authors", BookAuthor}, foreign_key: :author_id)
    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
