class IndexForeignKeysInCoreSystemEmails < ActiveRecord::Migration[4.2]
  def change
    add_index :core_system_emails, :account_id
    add_index :core_system_emails, :emailable_id
  end
end
