defmodule ManageLibrary.Library.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  alias ManageLibrary.Library.BookTag

  schema "tags" do
    field :title, :string
    has_many(:books, {"book_tags", BookTag}, foreign_key: :tag_id)
    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
