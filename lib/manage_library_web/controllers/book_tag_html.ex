defmodule ManageLibraryWeb.BookTagHTML do
  use ManageLibraryWeb, :html

  embed_templates "book_tag_html/*"

  @doc """
  Renders a book_tag form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def book_tag_form(assigns)
end
