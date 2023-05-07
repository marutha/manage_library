defmodule ManageLibraryWeb.ISBNHTML do
  use ManageLibraryWeb, :html

  embed_templates "isbn_html/*"

  @doc """
  Renders a isbn form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def isbn_form(assigns)
end
