class IndexForeignKeysInCoreAccounts < ActiveRecord::Migration
  def change
    add_index :core_accounts, :default_site_id
  end
end
