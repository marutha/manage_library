defmodule ManageLibrary.Library.Book do
  use Ecto.Schema
  import Ecto.Changeset

  schema "books" do
    field :description, :string
    field :dop, :date
    field :isbn_id, :integer
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :isbn_id, :description, :dop])
    |> validate_required([:name, :isbn_id, :description, :dop])
  end
end
