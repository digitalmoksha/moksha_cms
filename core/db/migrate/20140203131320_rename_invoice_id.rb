class RenameInvoiceId < ActiveRecord::Migration[4.2]
  def up
    remove_column   :core_accounts, :invoice_id_counter
    add_column      :core_accounts, :next_invoice_num, :integer, :default => 1000
  end

  def down
    remove_column   :core_accounts, :next_invoice_num
    add_column      :core_accounts, :invoice_id_counter, :integer
  end
end
