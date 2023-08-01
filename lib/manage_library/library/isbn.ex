defmodule ManageLibrary.Library.ISBN do
  use Ecto.Schema
  import Ecto.Changeset

  alias ManageLibrary.Library.Book
  schema "isbns" do
    field :isbn, :string
    belongs_to(:book, Book)
    timestamps()
  end

  @doc false
  def changeset(isbn, attrs) do
    isbn
    |> cast(attrs, [:isbn])
    |> validate_required([:isbn])
  end
end
