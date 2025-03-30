defmodule CommonLedgerWeb.ProjectHTML do
  use CommonLedgerWeb, :html

  embed_templates "project_html/*"

  @doc """
  Renders a project form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def project_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} action={@action}>
      <.input field={f[:name]} type="text" label="Name" />
      <:actions>
        <.button>Save Project</.button>
      </:actions>
    </.simple_form>
    """
  end
end
