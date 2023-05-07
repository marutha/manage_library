defmodule ManageLibrary.Repo.Migrations.CreateIsbns do
  use Ecto.Migration

  def change do
    create table(:isbns) do
      add :isbn, :string

      timestamps()
    end
  end
end
