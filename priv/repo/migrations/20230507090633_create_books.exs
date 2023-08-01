defmodule ManageLibrary.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :isbn, :integer
      add :description, :text
      add :dop, :date

      timestamps()
    end
  end
end
