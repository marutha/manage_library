defmodule ManageLibrary.Repo.Migrations.AddRelations do
  use Ecto.Migration

  def up do
    alter table("books") do
      modify :isbn_id, references("isbns")
    end
    alter table("book_authors") do
      modify :book_id, references("books")
      modify :author_id, references("authors")
    end
    alter table("book_tags") do
      modify :book_id, references("books")
      modify :tag_id, references("tags")
    end
  end

  def down do
    drop constraint("books", "books_isbn_id_fkey")
    drop constraint("book_authors", "book_authors_book_id_fkey")
    drop constraint("book_authors", "book_authors_author_id_fkey")
    drop constraint("book_tags", "book_tags_book_id_fkey")
    drop constraint("book_tags", "book_tags_tag_id_fkey")
  end
end
