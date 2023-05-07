defmodule ManageLibraryWeb.BookAuthorHTML do
  use ManageLibraryWeb, :html

  embed_templates "book_author_html/*"

  @doc """
  Renders a book_author form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def book_author_form(assigns)
end
