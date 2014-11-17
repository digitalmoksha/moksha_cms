# This migration comes from dm_core (originally 20140203131320)
class RenameInvoiceId < ActiveRecord::Migration
  def up
    remove_column   :core_accounts, :invoice_id_counter
    add_column      :core_accounts, :next_invoice_num, :integer, :default => 1000
  end

  def down
    remove_column   :core_accounts, :next_invoice_num
    add_column      :core_accounts, :invoice_id_counter, :integer
  end
end
