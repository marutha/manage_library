defmodule ManageLibrary.Repo.Migrations.CreateBookAuthors do
  use Ecto.Migration

  def change do
    create table(:book_authors) do
      add :book_id, :integer
      add :author_id, :integer

      timestamps()
    end
  end
end
