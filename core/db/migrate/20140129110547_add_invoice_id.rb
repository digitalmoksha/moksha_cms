class AddInvoiceId < ActiveRecord::Migration[4.2]
  def change
    # used to track an atomically increasing invoice id for an account (used in payments)
    add_column  :core_accounts, :invoice_id_counter, :integer
  end
end
