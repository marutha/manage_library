defmodule ManageLibrary.Repo.Migrations.CreateBookTags do
  use Ecto.Migration

  def change do
    create table(:book_tags) do
      add :book_id, :integer
      add :tag_id, :integer

      timestamps()
    end
  end
end
