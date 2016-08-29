class AddInvoiceId < ActiveRecord::Migration
  def change
    # used to track an atomically increasing invoice id for an account (used in payments)
    add_column  :core_accounts, :invoice_id_counter, :integer
  end
end
