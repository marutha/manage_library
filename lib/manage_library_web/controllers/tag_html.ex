defmodule ManageLibraryWeb.TagHTML do
  use ManageLibraryWeb, :html

  embed_templates "tag_html/*"

  @doc """
  Renders a tag form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def tag_form(assigns)
end
