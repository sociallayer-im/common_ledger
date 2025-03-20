defmodule CommonLedgerWeb.LedgerHTML do
  use CommonLedgerWeb, :html

  embed_templates "ledger_html/*"

  @doc """
  Renders a ledger form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def ledger_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@changeset} action={@action}>
      <.input field={f[:name]} type="text" label="Name" />
      <.input field={f[:description]} type="textarea" label="Description" />
      <.input
        field={f[:currency_type]}
        type="select"
        label="Currency"
        options={["USD", "EUR", "GBP", "JPY", "CNY"]}
      />
      <:actions>
        <.button>Save Ledger</.button>
      </:actions>
    </.simple_form>
    """
  end
end