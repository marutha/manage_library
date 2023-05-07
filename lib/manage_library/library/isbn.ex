defmodule ManageLibrary.Library.ISBN do
  use Ecto.Schema
  import Ecto.Changeset

  schema "isbns" do
    field :isbn, :string

    timestamps()
  end

  @doc false
  def changeset(isbn, attrs) do
    isbn
    |> cast(attrs, [:isbn])
    |> validate_required([:isbn])
  end
end
