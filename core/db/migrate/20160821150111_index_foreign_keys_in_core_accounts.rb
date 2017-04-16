class IndexForeignKeysInCoreAccounts < ActiveRecord::Migration[4.2]
  def change
    add_index :core_accounts, :default_site_id
  end
end
