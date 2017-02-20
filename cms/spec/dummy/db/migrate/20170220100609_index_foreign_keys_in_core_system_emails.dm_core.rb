# This migration comes from dm_core (originally 20160821150119)
class IndexForeignKeysInCoreSystemEmails < ActiveRecord::Migration
  def change
    add_index :core_system_emails, :account_id
    add_index :core_system_emails, :emailable_id
  end
end
